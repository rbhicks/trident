Feature: PE Template

  Scenario Outline: Successful substitution of template field for an offset
    Given A Dos Header template and a valid field name
    When A valid "<field_name>" is referenced
    Then The offset returned should match the <expected_offset>

    Examples:
    | field_name        | expected_offset |
    | pe_header_address |              60 |
    | reserved_1        |              40 |

  Scenario Outline: Successful calculation of a valid address
    Given A Dos Header template and a valid calculated address method
    When A valid "<calculated_address>" is calculated
    Then The address returned should match the <expected_address>

    Examples:
    | calculated_address | expected_address |
    | pe_header          |              232 |
    
  Scenario Outline: Failed substitution due to an invalid field name
    Given A Dos Header template and an invalid field name
    When An invalid "<field_name>" is referenced
    Then Then a NoMethoderror exception should be thrown for the invalid field name

    Examples:
    | field_name    |
    | invalid_field |

   Scenario Outline: Failed calculation of an invalid address
    Given A Dos Header template and an invalid calculated address method
    When A invalid "<calculated_address>" is calculated
    Then Then a NoMethoderror exception should be thrown for the invalid address

    Examples:
    | calculated_address |
    | invalid_address    |


