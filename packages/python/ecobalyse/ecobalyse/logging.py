import logging

from rich.logging import RichHandler

from config import settings

logger = logging.getLogger(__name__)

logger.setLevel(settings.LOG_LEVEL)

handler = RichHandler(markup=True)
handler.setFormatter(logging.Formatter(fmt="%(message)s", datefmt="[%X]"))
logger.addHandler(handler)

logger.debug(f"Current log level: {logging.getLevelName(logger.getEffectiveLevel())}")
