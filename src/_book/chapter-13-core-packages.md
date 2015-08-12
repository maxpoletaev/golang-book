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

Прежде чем мы перейдем к работе с файлами, нужно узнать про пакет `io`. Пакет `io`
состоит из нескольких функций, но в основном, это интерфейсы, используемые в
других пакетах. Два основных интерфейса — это `Reader` и `Writer`. `Reader`
занимается чтением с помощью метода `Read`. `Writer` занимается записью с помощью
метода `Write`. Многие функции принимают в качестве аргумента `Reader` или
`Writer`. Например, пакет `io` содержит функцию `Copy`, которая копирует данные из
`Reader` во `Writer`:

    func Copy(dst Writer, src Reader) (written int64, err error)

Чтобы прочитать или записать `[]byte` или `string`, можно использовать структуру
`Buffer` из пакета `bytes`:

    var buf bytes.Buffer
    buf.Write([]byte("test"))

`Buffer` не требует инициализации и поддерживает интерфейсы `Reader` и `Writer`.
Вы можете конвертировать его в `[]byte` вызвав `buf.Bytes()`. Если нужно только
читать строки, можно так же использовать функцию `strings.NewReader`, которая
более эффективна, чем чтение в буфер.

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

Функция  передаваемая вторым аргументом вызывается для каждого файла и каталога в
корневом каталоге (в данном случае).

## Ошибки

Go имеет встроенный тип для сообщений об ошибках, который мы уже рассматривали
(тип `error`). Мы можем создать свои собственные типы сообщений об ошибках
используя функцию `New` из пакета `errors`.

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

Пустым значением `List` *(вероятно, опечатка и имелось ввиду `x` — прим. пер.)*
является пустой список (`*List` создаётся при вызове `list.New`). Значения
добавляются в список при помощи `PushBack`. Далее, мы перебираем каждый элемент в
списке, получая ссылку на следующий, пока не достигнем `nil`.

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

## Хэши и криптография

Функция хэширования принимает набор данных и уменьшает его до фиксированного
размера. Хэши используются в программировании повсеместно, начиная от поиска
данных, заканчивая быстрым детектированием изменений. Хэш-функции в Go
подразделяются на две категории: криптографические и некриптографические.

Некриптографические функции можно найти в пакете `hash`, который включает такие
алгоритмы как `adler32`, `crc32`, `crc64` и `fnv`. Вот пример использования
`crc32`:

    package main

    import (
        "fmt"
        "hash/crc32"
    )

    func main() {
        h := crc32.NewIEEE()
        h.Write([]byte("test"))
        v := h.Sum32()
        fmt.Println(v)
    }

Объект `crc32` реализует интерфейс `Writer`, так что мы можем просто записать в
него набор байт, как и в любой другой `Writer`. После записи мы вызываем
`Sum32()`, который вернёт `uint32`. Обычным применением `crc32` является сравнение
двух файлов. Если значение `Sum32()` для обоих файлов одинаковы, то, весьма
вероятно (не со стопроцентной гарантией), содержимое этих файлов идентично. Если
же значения отличаются, значит файлы, безусловно, разные:

    package main

    import (
        "fmt"
        "hash/crc32"
        "io/ioutil"
    )

    func getHash(filename string) (uint32, error) {
        bs, err := ioutil.ReadFile(filename)
        if err != nil {
            return 0, err
        }
        h := crc32.NewIEEE()
        h.Write(bs)
        return h.Sum32(), nil
    }

    func main() {
        h1, err := getHash("test1.txt")
        if err != nil {
            return
        }
        h2, err := getHash("test2.txt")
        if err != nil {
            return
        }
        fmt.Println(h1, h2, h1 == h2)
    }

Криптографические хэш-функции аналогичны их некриптографическим коллегам, однако у
них есть одна особенность: их сложно обратить вспять. Очень сложно определить, что
за набор данных содержится в криптографическом хэше, поэтому такие хэши часто
используются в системах безопасности.

Одним из криптографических хэш-алгоритмов является SHA-1. Вот как можно его
использовать:

    package main

    import (
        "fmt"
        "crypto/sha1"
    )

    func main() {
        h := sha1.New()
        h.Write([]byte("test"))
        bs := h.Sum([]byte{})
        fmt.Println(bs)
    }

Этот пример очень похож на пример использования `crc32`, потому что оба они
реализуют интерфейс `hash.Hash`. Основное отличие в том, что в то время как
`crc32` вычисляет 32-битный хэш, `sha1` вычисляет 160-битный хэш. В Go нет
встроенного типа для хранения 160-битного числа, поэтому мы используем вместо него
срез размером 20 байт.

## Серверы

На Go очень просто создавать сетевые серверы. Сначала давайте взглянем, как
создать TCP сервер:

    package main

    import (
        "encoding/gob"
        "fmt"
        "net"
    )

    func server() {
        // listen on a port
        ln, err := net.Listen("tcp", ":9999")
        if err != nil {
            fmt.Println(err)
            return
        }
        for {
            // accept a connection
            c, err := ln.Accept()
            if err != nil {
                fmt.Println(err)
                continue
            }
            // handle the connection
            go handleServerConnection(c)
        }
    }

    func handleServerConnection(c net.Conn) {
        // receive the message
        var msg string
        err := gob.NewDecoder(c).Decode(&msg)
        if err != nil {
            fmt.Println(err)
        } else {
            fmt.Println("Received", msg)
        }
        
        c.Close()
    }

    func client() {
        // connect to the server
        c, err := net.Dial("tcp", "127.0.0.1:9999")
        if err != nil {
            fmt.Println(err)
            return
        }

        // send the message
        msg := "Hello World"
        fmt.Println("Sending", msg)
        err = gob.NewEncoder(c).Encode(msg)
        if err != nil {
            fmt.Println(err)
        }

        c.Close()
    }

    func main() {
        go server()
        go client()
        
        var input string
        fmt.Scanln(&input)
    }

Этот пример использует пакет `encoding/gob`, который позволяет легко кодировать
выходные данные, чтобы другие программы на Go (или конкретно эта программа, в
нашем случае) могли их прочитать. Дополнительные способы кодирования доступны в
пакете `encoding` (например `encoding/json`), а так-же в пакетах сторонних
разработчиков (например, можно использовать `labix.org/v2/mgo/bson` для работы с
BSON).

### HTTP

HTTP-серверы еще проще в настройке и использовании:

    package main

    import ("net/http" ; "io")

    func hello(res http.ResponseWriter, req *http.Request) {
        res.Header().Set(
            "Content-Type", 
            "text/html",
        )
        io.WriteString(
            res, 
            `<doctype html>
    <html>
        <head>
            <title>Hello World</title>
        </head>
        <body>
            Hello World!
        </body>
    </html>`,
        )
    }
    func main() {
        http.HandleFunc("/hello", hello)
        http.ListenAndServe(":9000", nil)
    }

`HandleFunc` обрабатывает URL-маршрут (`/hello`) с помощью указанной функции. Мы
так же можем обрабатывать статические файлы при помощи `FileServer`:

    http.Handle(
        "/assets/", 
        http.StripPrefix(
            "/assets/", 
            http.FileServer(http.Dir("assets")),
        ),
    )

### RPC

Пакеты `net/rpc` (remote procedure call — удаленный вызов процедур) и 
`net/rpc/jsonrpc` обеспечивают простоту вызова методов по сети (а не только из 
программы, в которой они используются).

    package main

    import (
        "fmt"
        "net"
        "net/rpc"
    )

    type Server struct {}
    func (this *Server) Negate(i int64, reply *int64) error {
        *reply = -i
        return nil
    }

    func server() {
        rpc.Register(new(Server))
        ln, err := net.Listen("tcp", ":9999")
        if err != nil {
            fmt.Println(err)
            return
        }
        for {
            c, err := ln.Accept()
            if err != nil {
                continue
            }
            go rpc.ServeConn(c)
        }
    }
    func client() {
        c, err := rpc.Dial("tcp", "127.0.0.1:9999")
        if err != nil {
            fmt.Println(err)
            return
        }
        var result int64
        err = c.Call("Server.Negate", int64(999), &result)
        if err != nil {
            fmt.Println(err)
        } else {
            fmt.Println("Server.Negate(999) =", result)
        }
    }
    func main() {
        go server()
        go client()
        
        var input string
        fmt.Scanln(&input)
    }

Эта программа похожа на пример использования TCP-сервера, за исключением того, 
что теперь мы создали объект, который содержит методы, доступные для вызова, 
а затем вызвали `Negate` из функции-клиента. Посмотрите документацию по 
`net/rpc` для получения дополнительной информации.

## Получение аргументов из командной строки

При вызове команды в консоли, есть возможность передать ей определенные 
аргументы. Мы видели это на примере вызова команды `go`:

    go run myfile.go

`run` и `myfile.go` являются аргументами. Мы так же можем передать команде 
флаги:

    go run -v myfile.go

Пакет `flag` позволяет анализировать аргументы и флаги, переданные нашей 
программе. Вот пример программы, которая генерирует число от 0 до 6. Но мы 
можем изменить максимальное значение, передав программе флаг `-max=100`.

    package main

    import ("fmt";"flag";"math/rand")

    func main() {
        // Define flags
        maxp := flag.Int("max", 6, "the max value")
        // Parse
        flag.Parse()
        // Generate a number between 0 and max
        fmt.Println(rand.Intn(*maxp))
    }

Любые дополнительные не-флаговые аргументы могут быть получены с помощью 
`flag.Args()` которая вернет `[]string`.

## Синхронизация примитивов

Предпочтительный способ справиться с параллелизмом и синхронизацией в Go, с 
помощью горутин и каналов уже описан в главе 10. Однако, Go предоставляет более 
традиционные способы работать с процедурами в отдельных потоках, в пакетах 
`sync` и `sync/atomic`.

### Мьютексы

Мьютекс (или взаимная блокировка) единовременно блокирует часть кода в одном
потоке, а  так же используется для защиты общих ресурсов из не-атомарных 
операций. Вот  пример использования мьютекса:

    package main

    import (
        "fmt"
        "sync"
        "time"
    )
    func main() {
        m := new(sync.Mutex)
        
        for i := 0; i < 10; i++ {
            go func(i int) {
                m.Lock()
                fmt.Println(i, "start")
                time.Sleep(time.Second)
                fmt.Println(i, "end")
                m.Unlock()
            }(i)
        }

        var input string
        fmt.Scanln(&input)
    }

Когда мьютекс (`m`) заблокирован из одного процесса, любые попытки повторно
блокировать его из других процессов приведут к блокировке самих процессов до тех
пор, пока мьютекс не будет разблокирован. Следует  проявлять большую
осторожность при использовании мьютексов или примитивов  синхронизации из пакета
`sync/atomic`.

Традиционное многопоточное программирование является достаточно сложным: 
сделать ошибку просто, а обнаружить её трудно, поскольку она может зависеть от 
специфичных и редких обстоятельств. Одна из сильных сторон Go в том, что он 
предоставляет намного более простой и безопасный способ распараллеливания 
задач, чем потоки и блокировки.
