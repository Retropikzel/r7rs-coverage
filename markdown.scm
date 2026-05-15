(import (scheme base)
        (scheme write)
        (scheme file)
        (chibi csv)
        (srfi 1))

(define port (open-input-file "results.csv"))
(define implementations '())
(define rows '())

(csv-map
  (lambda (row)
    (when (not (member (car row) implementations))
      (set! implementations (cons (car row) implementations)))
    (set! rows (cons row rows)))
  (csv-read->list)
  port)

(define result
  (append
    (list
      (cons "Test"
            (filter-map
              (lambda (row)
                (if (equal? (car row) (car implementations))
                  (apply
                    string-append
                    (map (lambda (item)
                           (string-append item " "))
                         (list-tail row 4)))
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
      implementations)))

(for-each
  (lambda (line)
    (for-each
      (lambda (item)
        (map display `("| " ,item " ")))
      line)
    (map display '(" |" #\newline)))
  (apply zip result))


