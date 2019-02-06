Feature: Move Absolute

  Scenario Outline: Successful move to an absolute offset in the scan buffer
    Given a move_absolute action with a good offset
    When the engine.move_absolute with the good <input_offset> action is taken
    Then the engine's <current_offset> should be <input_offset>

    Examples:
    | input_offset | current_offset |
    |           19 |             19 |

  Scenario Outline: Failed move to an absolute offset overflowing or underflowing the scan buffer
    Given a move_absolute action with a bad offset
    When the engine.move_absolute with the bad <input_offset> action is taken
    Then scan should fail with an AbsoluteOffsetInvalid exception

    Examples:
    | input_offset |
    |      3000000 |
    |           -1 |


