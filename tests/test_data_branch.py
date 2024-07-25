from lib.ecobalyse_github import extract_branch_name


def test_extract_data_branch_name(client):
    branch_name = extract_branch_name("ecobalyse_data: test_branch_name")
    assert branch_name == "test_branch_name"

    branch_name = extract_branch_name("nstnsnecobalyse_data: test_branch_name nstnstn")
    assert branch_name == "test_branch_name"

    branch_name = extract_branch_name("""tnsrtntntsr
    nstnsnecobalyse_data: test_branch_name nstnstn

    eaiuiuea""")
    assert branch_name == "test_branch_name"

    branch_name = extract_branch_name(
        "nstnsnecobalyse_data: test_branch_name/9./_- nstnstn"
    )
    assert branch_name == "test_branch_name/9./_-"

    # We should not include invalid characters in the match
    branch_name = extract_branch_name(
        "nstnsnecobalyse_data: test_bran<ch_name/9./_- nstnstn"
    )
    assert branch_name == "test_bran"
