(import (scheme base)
        (scheme write)
        (scheme file)
        (chibi csv)
        (srfi 1)
        (srfi 166))

(define port (open-input-file "results.csv"))
(define implementations '())
(define rows '())

(csv-map
  (lambda (row)
    (when (not (member (car row) implementations))
      (set! implementations (cons (car row)
                                  implementations)))
    (set! rows (cons row rows)))
  (csv-read->list)
  port)

(define result
  (append
    (list
      (cons "Library"
            (filter-map
              (lambda (row)
                (if (equal? (car row)
                            (car implementations))
                         (list-ref row 2)
                  #f))
              rows)))
    (list
      (cons "Test"
            (filter-map
              (lambda (row)
                (if (equal? (string-append (car row)
                                           "-"
                                           (list-ref row 1))
                            (car implementations))
                  (string-append
                    (list-ref row 4)
                    " ("
                    (list-ref row 5)
                    ")")
                  #f))
              rows)))
    (map
      (lambda (implementation)
        (cons implementation
              (filter-map
                (lambda (row)
                  (if (equal? (car row) implementation)
                    (list-ref row 3)
                    #f))
                rows)))
      (reverse implementations))))

(define result-strings
  (map (lambda (line)
         (apply string-append
                (append (map (lambda (item)
                               (string-append item "\n"))
                             line)
                        (list "\n"))))
       result))

(show #t
      (apply tabular
             (apply append
                    (append
                      (map (lambda (line)
                             (list "|" (each line)))
                           result-strings)
                      (list (list "|"))))))


