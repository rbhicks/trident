Feature: Match

  Scenario Outline: Successful match at the current offset of the scan buffer
    Given a match action for the <current_offset> with a matching sequence
    When the engine.match with a matching "<sequence>" action is taken
    Then true is returned

    Examples:
      | current_offset | sequence    |
      |            240 | 65 9A EF 4A |
      |            240 | ?? 9A EF 4A |
      |            240 | ?? ?? ?? ?? |

  Scenario Outline: Unsuccessful match at the current offset of the scan buffer
    Given a match action for the <current_offset> with an unmatching sequence
    When the engine.match with an unmatching "<sequence>" action is taken
    Then false is returned

    Examples:
      | current_offset | sequence    |
      |            240 | 77 9A EF 4A |

  Scenario Outline: A match failure
    Given a match action for the <current_offset> with an invalid sequence
    When the engine.match with an invalid "<sequence>" action is taken
    Then the scan will fail with an InvalidMatchSize exception

    # since we can't make a gigantic sequence
    # we'll reuse the failing one from above
    # but we'll make it huge in the step before
    # the call to match
    Examples:
      | current_offset | sequence    |
      |            240 | 77 9A EF 4A |
      |            240 |             |


