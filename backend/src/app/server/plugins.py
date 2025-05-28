from advanced_alchemy.extensions.litestar import SQLAlchemyPlugin
from app.config import app as config
from litestar.plugins.problem_details import ProblemDetailsPlugin
from litestar.plugins.structlog import StructlogPlugin

alchemy = SQLAlchemyPlugin(config=config.alchemy)
problem_details = ProblemDetailsPlugin(config=config.problem_details)
structlog = StructlogPlugin(config=config.log)
