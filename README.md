# Topolegal

Script para descargar los boletines judiciales en México.


## Pre-Requisitos
```bash
gem install nokogiri
gem install typhoeus
gem install mechanize
```

## Instalación

```bash
git clone https://github.com/eleloya/topolegal.git
```

## Uso del script

```bash
./topo.rb estado:accion

Estados:
 - BajaCalifornia
 - Jalisco
Acciones:
 - Juzgados, Boletines
```

## Ejemplo
Accion Juzgados
```bash
./topo.rb Jalisco:Juzgados
JUZGADO PRIMERO DE LO CIVIL
JUZGADO SEGUNDO DE LO CIVIL
JUZGADO TERCERO DE LO CIVIL
JUZGADO CUARTO DE LO CIVIL
JUZGADO QUINTO DE LO CIVIL
JUZGADO SEXTO DE LO CIVIL
JUZGADO SEPTIMO DE LO CIVIL
```
Accion Boletines
```bash
/topo.rb Jalisco:Boletines
[Jalisco, JUZGADO SEGUNDO DE LO CIVIL, 29-04-2015, 1549/96, 'MERCANTIL EJECUTIVO, CJWTC INMUEBLES, S.A. DE C.V. vs. GONZALEZ BUSTOS RAUL, Se ordena extraer del archivo']
[Jalisco, JUZGADO SEGUNDO DE LO CIVIL, 29-04-2015, 1254/99, 'CIVIL SUMARIO, SUAREZ SOLANO IGNACIO vs. VAZQUEZ ALVAREZ JOSE Y SOC., Gírese oficio recordatorio']
[Jalisco, JUZGADO SEGUNDO DE LO CIVIL, 29-04-2015, 162/2000, 'CIVIL ORDINARIO, RIOS MAGALLANES RODOLFO AGUSTIN vs. GOMEZ GARCIA ALBERTO, Fórmese cuadernillo, una vez que']
.....
.....
```

## Como contribuir

**Agregando estados que no tienen scrapper todavia.**

Te preguntaras ¿Como agrego un estado? ¿Por donde empiezo?

### En corto
 Solo sigue el ejemplo en "estados/Ejemplo"

### La explicación larga
Necesitamos dos archivos. **boletines.rb** y **juzgados.rb**

No importa si utilizas nokogori, mechanize, o la gema de tu preferencia para hacer el scrapping. Lo importante es que sigas el formato establecido por el ejemplo.

Conserva el nombre de los modulos, conserva el nombre del metodo run, y conserva el nombre de las variables que estan ahí. Solo cambia el nombre de la clase al nombre del estado. E inyecta tu magia en el metodo run.

De **juzgados.rb** espero un resultado con el siguiente formato:
```ruby
# Un arreglo de strings con todos los juzgados pertenecientes a un estado

['JUZGADO PRIMERO DE LO CIVIL', 'JUZGADO SEGUNDO DE LO CIVIL',
  'JUZGADO TERCERO DE LO CIVIL' ....]
```

De **boletines.rb** espero un resultado con el siguiente formato
```ruby
# Un arreglo de Topolegal::Expediente con todos los boletines pertenecientes a un estado

[<Topolegal::Expediente:0x007f9e748cd808>,
   <Topolegal::Expediente:0x007f9e748cd834>,
    <Topolegal::Expediente:0x007f9e748cd822, ....]

# Asi es como se ve un objeto tipo Expediente
# [#<Topolegal::Expediente:0x007f859c93ec60
#  @descripcion="MERCANTIL EJECUTIVO, CJWTC INMUEBLES, S.A. DE C.V. vs. GONZALEZ BUSTOS RAUL, Se ordena extraer del archivo",
#  @estado="Jalisco",
#  @expediente="1549/96",
#  @fecha="29-04-2015",
#  @juzgado="JUZGADO SEGUNDO DE LO CIVIL">, ...]
```



## Como subir mi contribución

1. Fork it ( https://github.com/eleloya/topolegal/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
