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
      (set! implementations (cons (car row) implementations)))
    (set! rows (cons row rows)))
  (csv-read->list)
  port)

(define result
  (apply zip
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
             implementations))))

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


