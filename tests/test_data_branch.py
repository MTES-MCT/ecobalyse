from bin.extract_data_branch_from_pr import extract_branch_name


def test_extract_data_branch_name(client):
    branch_name = extract_branch_name("ecobalyse_data: test_branch_name")
    assert branch_name == "test_branch_name"

    branch_name = extract_branch_name("nstnsnecobalyse_data: test_branch_name nstnstn")
    assert branch_name == "test_branch_name"

    branch_name = extract_branch_name("""tnsrtntntsr
    nstnsnecobalyse_data: test_branch_name nstnstn

    eaiuiuea""")
    assert branch_name == "test_branch_name"
