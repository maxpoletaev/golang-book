---
title:  "Стандартная библиотека"
layout: "chapter"

---

Вместо того, чтобы каждый раз писать всё с нуля, реальный мир программирования
требует от нас умения взаимодействовать с уже существующими библиотеками. В этой
главе мы рассмотрим самые часто используемые пакеты, включенные в Go.

Предупреждаю: некоторые библиотеки достаточно очевидны (или были объяснены в
предыдущих главах), многие из библиотек, включённых в Go требуют специальных
знаний (например: криптография). Объяснение этих технологий выходит за рамки
этой книги.

## Строки

Go содержит большое количество функций для работы со строками в пакете `string`:

    package main

    import (
        "fmt"
        "strings"
    )

    func main() {
        fmt.Println(    
            // true
            strings.Contains("test", "es"), 

            // 2
            strings.Count("test", "t"),

            // true
            strings.HasPrefix("test", "te"), 

            // true
            strings.HasSuffix("test", "st"), 

            // 1
            strings.Index("test", "e"), 

            // "a-b"
            strings.Join([]string{"a","b"}, "-"),

            // == "aaaaa"
            strings.Repeat("a", 5), 

            // "bbaa"
            strings.Replace("aaaa", "a", "b", 2),

            // []string{"a","b","c","d","e"}
            strings.Split("a-b-c-d-e", "-"), 

            // "test"
            strings.ToLower("TEST"), 

            // "TEST"
            strings.ToUpper("test"), 

        )
    }

Иногда нам понадобится работать с бинарными данными. Чтобы преобразовать строку
в набор байт (и наоборот), выполните следующие действия:

    arr := []byte("test")
    str := string([]byte{'t','e','s','t'})

## Ввод / Вывод

Прежде чем мы перейдем к работе с файлами, нужно узнать про пакет `io`.
Пакет `io` состоит из нескольких функций, но в основном, это интерфейсы,
используемые в других пакетах. Два основных интерфейса — это `Reader` и
`Writer`. `Reader` занимается чтением с помощью метода `Read`. `Writer`
занимается записью с помощью метода `Write`. Многие функции принимают в
качестве аргумента `Reader` или `Writer`. Например, пакет `io` содержит
функцию `Copy`, которая копирует данные из `Reader` во `Writer`:

    func Copy(dst Writer, src Reader) (written int64, err error)

Чтобы прочитать или записать `[]byte` или `string`, можно использовать стурктуру
`Buffer` из пакета `bytes`:

    var buf bytes.Buffer
    buf.Write([]byte("test"))

`Buffer` не требует инициализации и поддерживает интерфейсы `Reader` и `Writer`.
Вы можете конвертировать его в `[]byte` вызвав `buf.Bytes()`. Если нужно только
читать строки, можно так же использовать функцию `strings.NewReader`, которая
более эффективна, чем чтение в буффер.

## Файлы и папки

Для открытия файла Go использует функцию `Open` из пакета `os`. Вот пример того,
как прочитать файл и вывести его содержимое в консоль:

    package main

    import (
        "fmt"
        "os"
    )

    func main() {
        file, err := os.Open("test.txt")
        if err != nil {
            // handle the error here
            return
        }
        defer file.Close()
        
        // get the file size
        stat, err := file.Stat()
        if err != nil {
            return
        }
        // read the file
        bs := make([]byte, stat.Size())
        _, err = file.Read(bs)
        if err != nil {
            return
        }

        str := string(bs)
        fmt.Println(str)
    }

Мы используем `defer file.Close()` сразу после открытия файла, чтобы быть
уверенным, что файл будет закрыт после выполнения функции. Чтение файлов является
частым действием, так что вот самый короткий способ сделать это:

    package main

    import (
        "fmt"
        "io/ioutil"
    )

    func main() {
        bs, err := ioutil.ReadFile("test.txt")
        if err != nil {
            return
        }
        str := string(bs)
        fmt.Println(str)
    }

А вот так мы можем создать файл:

    package main

    import (
        "os"
    )

    func main() {
        file, err := os.Create("test.txt")
        if err != nil {
            // handle the error here
            return
        }
        defer file.Close()

        file.WriteString("test")
    }

Чтобы получить содержимое каталога, мы используем тот же `os.Open`, но передаём
ему путь к каталогу вместо имени файла. Затем вызывается функция `Readdir`:

    package main

    import (
        "fmt"
        "os"
    )

    func main() {
        dir, err := os.Open(".")
        if err != nil {
            return
        }
        defer dir.Close()

        fileInfos, err := dir.Readdir(-1)
        if err != nil {
            return
        }
        for _, fi := range fileInfos {
            fmt.Println(fi.Name())
        }
    }

Иногда мы хотим рекурсивно обойти каталоги (прочитать содержимое текущего и всех
вложенных каталогов). Это делается просто с помощью функции `Walk`,
предоставляемой пакетом `path/filepath`:

    package main

    import (
        "fmt"
        "os"
        "path/filepath"
    )

    func main() {
        filepath.Walk(".", func(path string, info os.FileInfo, err error) error {
            fmt.Println(path)
            return nil
        })
    }

Функция  передаваемая вторым аргументом вызывается для кажого файла и каталога в
корневом каталоге (в данном случае).

## Ошибки

Go имеет встроенный тип для сообщений об ошибках, который мы уже рассматривали
(тип `error`). Мы можем создать свои собственные типы сообщений об ошибках
используя функцию `New` из пакета `error`.

    package main

    import "errors"

    func main() {
        err := errors.New("error message")
    }

## Контейнеры и сортировки

В дополнение к спискам и картам, Go предоставляет еще несколько видов коллекций,
доступных в пакете `container`. В качестве примера рассмотрим `container/list`.

### Список

Пакет `container/list` реализует двусвязный список. Структура типа данных связного
списка выглядит следующим образом:

![](/img/chapter-13/01.png)

Каждый узел списка содержит значение (в нашем случае: 1, 2 или 3) и указатель на
следующий узел. Но так как это двусвязный список, узел так же содержит указатель
на предыдущий. Такой список может быть создан с помощью следующей программы:

    package main

    import ("fmt" ; "container/list")

    func main() {
        var x list.List
        x.PushBack(1)
        x.PushBack(2)
        x.PushBack(3)

        for e := x.Front(); e != nil; e=e.Next() {
            fmt.Println(e.Value.(int))  
        }
    }

Пустым значением `List` *(вероятно, опечатка и имелось ввиду `x` — прим. пер.)* является пустой список (`*List` создаётся при вызове
`list.New`). Значения добавляются в список при помощи `PushBack`. Далее, мы
перебираем каждый элемент в списке, получая ссылку на следующий, пока не достигнем
`nil`.

### Сортировка

Пакет `sort` содержит функции для сортировки произвольных данных. Есть несколько
предопределённых функций (для срезов, целочисленных значений и чисел с плавающей
точкой). Вот пример, как отсортировать ваши данные:

    package main

    import ("fmt" ; "sort")

    type Person struct { 
        Name string
        Age int
    }

    type ByName []Person

    func (this ByName) Len() int {
        return len(this)
    }
    func (this ByName) Less(i, j int) bool {
        return this[i].Name < this[j].Name
    }
    func (this ByName) Swap(i, j int) {
        this[i], this[j] = this[j], this[i]
    }

    func main() {
        kids := []Person{
            {"Jill",9},
            {"Jack",10},
        }
        sort.Sort(ByName(kids))
        fmt.Println(kids)
    }
