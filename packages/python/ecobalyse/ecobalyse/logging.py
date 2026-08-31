import importlib.util
import logging

from rich.logging import RichHandler

logger = logging.getLogger(__name__)

if importlib.util.find_spec("dynaconf") is not None:
    from config import settings

    logger.setLevel(settings.LOG_LEVEL)

handler = RichHandler(markup=True)
handler.setFormatter(logging.Formatter(fmt="%(message)s", datefmt="[%X]"))
logger.addHandler(handler)

logger.debug(f"Current log level: {logging.getLevelName(logger.getEffectiveLevel())}")
