from ecobalyse.github import extract_branch_name


def test_extract_data_branch_name():
    branch_name = extract_branch_name("ecobalyse-private: test_branch_name")
    assert branch_name == "test_branch_name"

    branch_name = extract_branch_name(
        "nstnsnecobalyse-private: test_branch_name nstnstn"
    )
    assert branch_name == "test_branch_name"

    branch_name = extract_branch_name("""tnsrtntntsr
    nstnsnecobalyse-private: test_branch_name nstnstn

    eaiuiuea""")
    assert branch_name == "test_branch_name"

    branch_name = extract_branch_name(
        "nstnsnecobalyse-private: test_branch_name/9./_- nstnstn"
    )
    assert branch_name == "test_branch_name/9./_-"

    # We should not include invalid characters in the match
    branch_name = extract_branch_name(
        "nstnsnecobalyse-private: test_bran<ch_name/9./_- nstnstn"
    )
    assert branch_name == "test_bran"
