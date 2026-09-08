import bw2calc
from bw2data import get_activity

from ecobalyse_data.logging import logger


def print_recursive_calculation(
    activity,
    lcia_method,
    amount=1,
    max_level=3,
    cutoff=1e-2,
    string_length=130,
    tab_character="  ",
    use_matrix_values=False,
    lca_obj=None,
    total_score=None,
    level=0,
    first=True,
):
    """Traverse a supply chain graph, and calculate the LCA scores of each component. Prints the result with the format:

    {tab_character * level }{fraction of total score} ({absolute LCA score for this input} | {amount of input}) {input activity}

    Args:
        activity: ``Activity``. The starting point of the supply chain graph.
        lcia_method: tuple. LCIA method to use when traversing supply chain graph.
        amount: int. Amount of ``activity`` to assess.
        max_level: int. Maximum depth to traverse.
        cutoff: float. Fraction of total score to use as cutoff when deciding whether to traverse deeper.
        string_length: int. Maximum length of printed string.
        file_obj: File-like object (supports ``.write``), optional. Output will be written to this object if provided.
        tab_character: str. Character to use to indicate indentation.
        use_matrix_values: bool. Take exchange values from the matrix instead of the exchange instance ``amount``. Useful for Monte Carlo, but can be incorrect if there is more than one exchange from the same pair of nodes.

    Normally internal args:
        _lca_obj: ``LCA``. Can give an instance of the LCA class (e.g. when doing regionalized or Monte Carlo LCA)
        _total_score: float. Needed if specifying ``_lca_obj``.

    Internal args (used during recursion, do not touch);
        __level: int.
        __first: bool.

    Returns:
        Nothing. Prints to ``sys.stdout`` or ``file_obj``

    """
    activity = get_activity(activity)

    if lca_obj is None:
        lca_obj = bw2calc.LCA({activity: amount}, lcia_method)
        lca_obj.lci()
        lca_obj.lcia()
        total_score = lca_obj.score
    elif total_score is None:
        raise ValueError
    else:
        lca_obj.redo_lcia({activity.id: amount})

        if abs(lca_obj.score) <= abs(total_score * cutoff):
            # logger.warning(f"->  {_lca_obj.score} below cutoff {abs(_total_score * cutoff)} for {activity}, returning.")
            return
    if first:
        logger.info("Fraction of score | Absolute score | Amount | Activity")
    message = f"{tab_character * level}{lca_obj.score / total_score:04.3g} | {lca_obj.score:5.4n} | {float(amount):5.4n} | {activity!s}"
    logger.info(message)
    if level < max_level:
        prod_exchanges = list(activity.production())
        if not prod_exchanges:
            prod_amount = 1
        elif len(prod_exchanges) > 1:
            logger.warning("Hit multiple production exchanges; aborting in this branch")
            return
        else:
            prod_amount = lca_obj.technosphere_matrix[
                lca_obj.dicts.product[prod_exchanges[0].input.id],
                lca_obj.dicts.activity[prod_exchanges[0].output.id],
            ]

        for exc in activity.technosphere():
            if exc.input.id == exc.output.id:
                continue

            if use_matrix_values:
                sign = (
                    -1
                    if exc.get("type") in ("technosphere", "generic technosphere")
                    else 1
                )
                tm_amount = (
                    lca_obj.technosphere_matrix[
                        lca_obj.dicts.product[exc.input.id],
                        lca_obj.dicts.activity[exc.output.id],
                    ]
                    * sign
                )
            else:
                tm_amount = exc["amount"]

            print_recursive_calculation(
                activity=exc.input,
                lcia_method=lcia_method,
                amount=amount * tm_amount / prod_amount,
                max_level=max_level,
                cutoff=cutoff,
                string_length=string_length,
                tab_character=tab_character,
                first=False,
                lca_obj=lca_obj,
                total_score=total_score,
                level=level + 1,
            )
