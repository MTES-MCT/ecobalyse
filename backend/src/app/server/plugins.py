from advanced_alchemy.extensions.litestar import SQLAlchemyPlugin
from litestar.plugins.problem_details import ProblemDetailsPlugin
from litestar.plugins.structlog import StructlogPlugin

from app.config import app as config

alchemy = SQLAlchemyPlugin(config=config.alchemy)
problem_details = ProblemDetailsPlugin(config=config.problem_details)
structlog = StructlogPlugin(config=config.log)
