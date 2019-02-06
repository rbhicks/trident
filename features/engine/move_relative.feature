Feature: Move Relative

  Scenario Outline: Successful move to a relative offset in the scan buffer
    Given a move_relative action with a good offset and this <starting_offset>
    When the engine.move_relative with the good <input_offset> action is taken
    Then the <starting_offset> minus the <input_offset> should equal the engine's <current_offset>

    Examples:
      | starting_offset | input_offset | current_offset |
      |              19 |           19 |             38 |
      |              19 |           -2 |             17 |

  Scenario Outline: Failed move to a relative offset overflowing or underflowing the scan buffer
    Given a move_relative action with a bad offset and this <starting_offset>
    When the engine.move_relative with the bad <input_offset> action is taken
    Then scan should fail with an RelativeOffsetInvalid exception

    Examples:
      | starting_offset | input_offset |
      |              19 |      3000000 |
      |              19 |     -3000000 |

