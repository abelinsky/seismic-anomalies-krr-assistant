from pathlib import Path

from loguru import logger
from tqdm import tqdm
import typer

import segyio
import numpy as np

from seismic_anomalies_krr_assistant.config import (
    PROCESSED_DATA_DIR,
    RAW_DATA_DIR,
)

app = typer.Typer()


@app.command()
def main(
    input_path: Path = RAW_DATA_DIR / "F3_seismic.segy",
    output_path: Path = PROCESSED_DATA_DIR / "F3_seismic.npy",
):
    logger.info("Reading SEG-Y...")
    # for i in tqdm(range(10), total=10):
    #     if i == 5:
    #         logger.info("Something happened for iteration 5.")

    with segyio.open(input_path, "r") as f:
        #  размеры из заголовков
        ilines = f.ilines  # inline номера
        xlines = f.xlines  # crossline номера
        samples = f.samples  # временные отсчёты (мс)

        logger.info(
            f"Inlines: {ilines[0]}–{ilines[-1]} (всего: {len(ilines)})"
        )
        logger.info(
            f"Crosslines: {xlines[0]}–{xlines[-1]} (всего: {len(xlines)})"
        )
        logger.info(
            f"Время: {samples[0]}–{samples[-1]} мс (отсчётов: {len(samples)})"
        )

        dt_microsec = f.bin[segyio.BinField.Interval]  # в микросекундах
        dt = dt_microsec / 1e6  # перевод в секунды
        logger.info(f"Временной шаг: {dt} с ({dt*1000} мс)")

        times = f.samples  # массив времён в миллисекундах
        logger.info(f"Время первого отсчёта: {times[0]} мс")
        logger.info(f"Время последнего отсчёта: {times[-1]} мс")
        logger.info(f"Шаг: {times[1] - times[0]} мс")

        # Загружаем все трассы в память
        traces = np.array([np.copy(tr) for tr in f.trace])

        # Преобразуем в 3D-куб: (inline, crossline, время)
        cube = traces.reshape(len(ilines), len(xlines), len(samples))

    logger.info(f"Форма куба: {cube.shape}")

    # Сохраняем в .npy
    np.save(output_path, cube)
    print(f"Сохранено: {output_path}")

    logger.success("Обработка завершена, файл *.segy преобразован в *.npy.")


if __name__ == "__main__":
    app()
