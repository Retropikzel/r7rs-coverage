(import (scheme base)
        (scheme write)
        (scheme file)
        (scheme char)
        (scheme process-context)
        (only (srfi 1) first second third fourth fifth)
        (only (srfi 28) format)
        (srfi 69)
        (only (srfi 95) sort)
        (only (srfi 152) string-split))

(define (nested-hash-table/put! table value . keys)
  ;"Put VALUE into nested TABLE by KEYS. Returns value."
  (let loop ((table table)
             (key (car keys))
             (keys (cdr keys)))
    (if (null? keys)
      (begin
        (hash-table-set! table key value)
        value)
      (let ((sub-table (hash-table-ref/default table key #f)))
        (if sub-table
          (loop sub-table (car keys) (cdr keys))
          (let ((sub-table (make-hash-table)))
            (hash-table-set! table key sub-table)
            (loop sub-table (car keys) (cdr keys))))))))

(define (nested-hash-table/get table default . keys)
  (let loop ((table table)
             (key (car keys))
             (keys (cdr keys)))
    (if (null? keys)
      (hash-table-ref/default table key default)
      (let ((sub-table (hash-table-ref/default table key #f)))
        (if sub-table
          (loop sub-table (car keys) (cdr keys))
          default)))))

(define (nested-hash-table/remove! table . keys)
  (let loop ((table table)
             (key (car keys))
             (keys (cdr keys)))
    (if (null? keys)
      (hash-table-delete! table key)
      (let ((sub-table (hash-table-ref/default table key #f)))
        (if sub-table
          (loop sub-table (car keys) (cdr keys))
          #t)))))

(define (symbol<? a b)
  (string<? (symbol->string a) (symbol->string b)))
(define (read-data)
  (with-input-from-file "results.csv"
    (lambda ()
      (let loop ((lines '()))
        (let ((line (read-line)))
          (if (eof-object? line)
              (map (lambda (x) (string-split x #\,))
                   (reverse lines))
              (loop (cons line lines))))))))

(define *data* (make-hash-table))
(define *schemes* '())
(define *groups* '())
(define *group-results* '())
(define *tests* (make-hash-table))

(define (symbol-downcase s)
  (string->symbol (string-downcase (symbol->string s))))

(define-syntax push
  (syntax-rules ()
    ((push x lst)
     (set! lst (cons x lst)))))

(define (parse-data)
  (let ((data (read-data)))
    (for-each
      (lambda (d)
        (let* ((impl (first d))
               (version (second d))
               (scheme (string->symbol (string-append impl "-" version)))
               (group (string->symbol (third d)))
               (result (symbol-downcase (string->symbol (fourth d))))
               (name (fifth d))
               (comments (apply string-append (list-tail d 5))))
          (nested-hash-table/put! *data* result group name comments scheme)
          (unless (memq scheme *schemes*)
            (push scheme *schemes*))
          (unless (memq group *groups*)
            (push group *groups*))
          (unless (member name (hash-table-ref/default *tests* group '()))
            (hash-table-set! *tests*
                             group
                             (cons name
                                   (hash-table-ref/default *tests*
                                                           group
                                                           '()))))))
      data)))

(define (get-res group test)
  (hash-table->alist (nested-hash-table/get *data* 'UNKNOWN group test)))

(define *current-id* 0)

(define (next-id)
  (let ((res (format #f "id~a" *current-id*)))
   (set! *current-id* (+ 1 *current-id*))
   res))

(define *console* (current-output-port))

(define (group-stats data group scheme)
  ;; (format *console* "group-stats ~a ~a ~a" data group scheme) (flush-output)
  (let ((gr (nested-hash-table/get data #f group))
        (pos 0)
        (neg 0))
    (hash-table-walk
      gr
      (lambda (k function)
        (hash-table-walk function
                         (lambda (k test)
                           (let ((r (hash-table-ref/default test scheme #f)))
                             (if r
                               (case r
                                 ((ok) (set! pos (+ pos 1)))
                                 ((error) (set! neg (+ neg 1)))
                                 (else (error "unknown result" r)))
                               (format *console*
                                       "ERROR: no result for ~a ~a ~a~%"
                                       data
                                       group
                                       scheme)))))))
    (format #f "~a ~a"
            (if (zero? pos) "" (format #f "<small>~a</small>✓" pos))
            (if (zero? neg) "" (format #f "<small>~a</small>×" neg)))))

(define format-group-row
  (lambda args
    (when (not (null? args))
      (format #t "<tr>")
      (for-each (lambda (item) (format #t "<th><b>~a</b></th>" item)) args)
      (format #t "</tr>"))))

(define format-row
  (lambda args
    (when (not (null? args))
      (format #t "<tr>")
      (format #t
              "<td id=\"~a\"><a href=\"#~a\">~a"
              (car args)
              (car args)
              (car args))
      (for-each
        (lambda (item)
          (format #t "<td>~a</td>" item))
        (cdr args))
      (format #t "</tr>"))))

(define (format-thead scheme-list)
  (format #t "<table border=1><thead><tr>")
  (for-each
    (lambda (scheme)
      (if (symbol? scheme)
        (let* ((parts (string-split (symbol->string scheme) #\-))
               (name (car parts))
               (version (cadr parts)))
          (format #t
                  "<th>~a <small>~a</small></th>"
                  name
                  version))
        (format #t "<th>~a</th>" scheme)))
    (cons "" scheme-list))
  (format #t "</tr></thead>"))

(define (count-result r scheme)
  (map
    (lambda (res)
      (if (eq? 'error (hash-table-ref/default (cdr res) scheme 'error))
        0
        1))
    r))

(define (collect-result-summary r scheme)
  (apply
    string-append
    (map
      (lambda (result)
        (string-append
          (if (equal? (hash-table-ref/default (cdr result) scheme 'error)
                      'ok)
            "✓ "
            "× ")
          (car result)
          "</br>"))
      r)))

(define (format-stats)
  (with-output-to-file
    "index.html"
    (lambda ()
      (set! *data* (make-hash-table))
      (set! *schemes* '())
      (set! *groups* '())
      (set! *group-results* (make-hash-table))
      (set! *tests* (make-hash-table))
      (parse-data)
      (let ((scheme-list (sort *schemes* (lambda (a b) (symbol<? a b)))))
        (format #t "<html><head><meta charset=\"utf-8\"/></head><body>")
        (format-thead scheme-list)
        (format #t "<tbody>")
        (for-each
          (lambda (group)
            (apply format-group-row
                   (cons (symbol->string group)
                         (map (lambda (scheme)
                                (group-stats *data* group scheme))
                              scheme-list)))
            (for-each
              (lambda (test)
                (let ((r (get-res group test))
                      (id (next-id)))
                  (apply
                    format-row
                    `(,test
                       ,@(map
                           (lambda (scheme)
                             (let* ((x (count-result r scheme))
                                    (ok (apply + x))
                                    (total (length x)))
                               (format "<details><summary>~a ~a/~a</summary>~a</br>~a</details>"
                                       (if (= ok total)
                                         "✓"
                                         (if (= 0 ok) "×" "◑"))
                                       ok
                                       total
                                       scheme
                                       (collect-result-summary r scheme))
                               ))
                           scheme-list)))))
              (sort (hash-table-ref/default *tests* group '())
                    (lambda (a b) (string<? a b)))))
          (sort *groups*
                (lambda (a b) (symbol<? a b))))
        (format #t "</tbody></table></body></html>")))))

(format-stats)
(exit)
