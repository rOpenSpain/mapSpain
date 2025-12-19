# Errors

    Code
      esp_move_can(teide)
    Condition
      Error in `esp_move_can()`:
      ! `x` should be an <sf> or <sfc> object, not a data frame.

# Internal

    Code
      sf::st_coordinates(res)
    Output
                X      Y
      [1,] 550000 920000

---

    Code
      sf::st_coordinates(res)
    Output
                X      Y
      [1,] 550000 920000

# Several

    Code
      sf::st_coordinates(res)
    Output
                X      Y
      [1,]      0      0
      [2,] 550000 920000

---

    Code
      sf::st_coordinates(res2)
    Output
                   X        Y
      [1,]  0.000000  0.00000
      [2,] -5.059266 18.01146

---

    Code
      sf::st_coordinates(res)
    Output
                X      Y
      [1,]      0      0
      [2,] 550000 920000

---

    Code
      sf::st_coordinates(res2)
    Output
                   X        Y
      [1,]  0.000000  0.00000
      [2,] -5.059266 18.01146

