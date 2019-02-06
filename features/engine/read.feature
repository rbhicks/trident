Feature: Read

  Scenario Outline: Successful read from the current offset of the scan buffer
    Given a read action for the <current_offset> with a valid size
    When the engine.read with a valid read <size> action is taken
    Then a binary string matching the original "<source_string>" is returned

    Examples:
      | current_offset | size | source_string |
      |            240 |    4 | 65 9A EF 4A   |


  Scenario Outline: Failed read from the current offset of the scan buffer
    Given a read action for the <current_offset> with an invalid size
    When the engine.read with an invalid read <size> action is taken
    Then the scan will fail with an InvalidReadSize exception

    Examples:
      | current_offset |    size |
      |            240 | 3000000 |
      |            240 |      -4 |


