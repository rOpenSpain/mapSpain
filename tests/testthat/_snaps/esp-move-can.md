# esp_move_can() requires an sf or sfc object

    Code
      esp_move_can(teide)
    Condition
      Error in `esp_move_can()`:
      ! `x` must be an <sf> or <sfc> object, not a data frame.

---

    Code
      esp_move_can()
    Condition
      Error in `esp_move_can()`:
      ! `x` must be supplied.

# move_can() identifies Canary geometries from regional codes

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

# move_can() moves only Canary rows in mixed datasets

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

