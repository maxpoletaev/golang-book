---
title:  "Пакеты, или повторное использование кода"
layout: "chapter"

---

Пакеты, или повторное использование кода


Го разработан как язык, который поощрает хорошие инженерные практики. Одна из этих практик, позволяющих создавать высококачественное программное обеспечение, является повторное использование кода, называемое  DRY - "Don't Repeat Yourself." - (аккроним, в переводе с английского) - "не повторяйтесь!"
Как мы уже видели в 7 главе, функции являются первым уровнем повторного использование кода. Но Го поддерживает ещё один механизм для повторного использование кода - пакеты.
Почти любая программа, которую мы видели, включает эту линию кода:

    import "fmt"

`fmt` - это имя пакета, включающего множество функций, связанных с форматированием строк и выводом на экран.
Данный метод распространение кода обусловленно тремя причинами:


* Снижение вероятности дублирование имён функций, что позволяет именам быть простыми и краткими
* Организация кода для упрощения поиска повторно используемых конструкций
* Ускорение компиляции, так как мы должны перекомпилировать только части программы. Не смотря на то, что мы используем пакет `fmt`, мы не должны перекомпилировать его при каждом использовании


## Создание пакета

Использование пакетов имеют смысл, только когда они востребованны в отдельной программе.
Без неё исползьзовать пакеты невозможно.
Let's create an application that will use a package we will write.
 Давайте создадим программу, которая будет использовать наш пакет.
 Создадим директорию в `~/Go/src/golang-book` под названием `chapter11`.
  В ней создадим файл `main.go` с этим кодом:

    package main

    import "fmt"
    import "golang-book/chapter11/math"

    func main() {
        xs := []float64{1,2,3,4}
        avg := math.Average(xs)
        fmt.Println(avg)
    }

А теперь создадим ещё одну директорию внутри `chapter11` под названием `math`
В ней мы создадим файл `math.go` с этим кодом:

    package math

    func Average(xs []float64) float64 {
        total := float64(0)
        for _, x := range xs {
            total += x
        }
        return total / float64(len(xs))
    }

C помощью терминала в папке `math` запустите команду `go install`
В результате файл `math.go` скомпилируется в объектный файл `~/Go/pkg/os_arch/golang-book/chapter11/math.a`
(при этом `os` - может быть `Windows`, a `arch`, например, - amd64)

Теперь вернёмся в директорию `chapter11` и выполним `go run main.go`. Программа выведет `2.5` на экран.
Подведём итоги:

* `math` является встроенным пакетом, но так как пакеты Go используют иерархические наименование, мы можем перекрыть уже используемое наименование, в данном случае, настоящий пакет `math` и будет называться `math`, а наш - `golang-book/chapter11/math`.
* Кодна мы импортируем библиотеку, мы используем её полное наименование  `import "golang-book/chapter11/math"`, но внутри файла `math.go` мы используем только последнюю часть названия - `package math`.
* Мы используем только краткое имя `math` когда мы обращаемся к функциям  в нашем пакете. Если же мы хотим использовать оба пакета, то мы можем использовать псевдоним:


    import m "golang-book/chapter11/math"

    func main() {
        xs := []float64{1,2,3,4}
        avg := m.Average(xs)
        fmt.Println(avg)
    }

В этом коде `m` - псевдоним.

* Возможно Вы заметили, что каждая функция в пакете начинается с заглавной буквы. Любая сущность языка Го, которая  начинается с заглавной буквы, означает, что другие пакеты и программы могут использовать эту сущность. Если бы мы назвали нашу функцию `average`, а не `Average`, то наша главная программа не смогла бы обратиться к ней.
* Рекомендуется делать явными только те сущности нашего пакета, которые могут быть использованы другими пакетами, и прятать все остальные, служебные функции, не используемые в других пакета. Данный подход позволяет производить изменения в скрытых частях пакета без риска нарушить работу других программ, и это облегчает использование нашего пакета
* Имена пакетов совпадают с директориями, в которых они размещены. Данное правило можно обойти, но делать это нежелательно.


Documentation

Go has the ability to automatically generate documentation for packages we write in a similar way to the standard package documentation. In a terminal run this command:

godoc golang-book/chapter11/math Average
You should see information displayed for the function we just wrote. We can improve this documentation by adding a comment before the function:

// Finds the average of a series of numbers
func Average(xs []float64) float64 {
If you run go install in the math folder, then re-run the godoc command you should see our comment below the function definition. This documentation is also available in web form by running this command:

godoc -http=":6060"
and entering this URL into your browser:

http://localhost:6060/pkg/
You should be able to browse through all of the packages installed on your system.

Problems

Why do we use packages?

What is the difference between an identifier that starts with a capital letter and one which doesn’t? (Average vs average)

What is a package alias? How do you make one?

We copied the average function from chapter 7 to our new package. Create Min and Max functions which find the minimum and maximum values in a slice of float64s.

How would you document the functions you created in #3?