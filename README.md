# API UserInfo and Geocoords

Com base no deguinte payload JSON :
```
  {
    "name":"Jane Doe",
    "city":"London"
  }
```
Os resources disponiveis permitem guardar esta informação numa base de dados assim como, consultar, alterar e apagar o mesmo registo.
Com base no valor do elemento ``"city"``, é feito um request a uma API externa que permite obter as coordenadas geograficas da mesma e guarda-las na base de daods
