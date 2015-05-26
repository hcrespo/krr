(in-package :fol)

(defun troca (form)
  (do ((f form (cdr f))
       (i 1)
       (cf nil))
      ((null f) (reverse cf))
      (let ((p (car f)))
         (if (and (listp p)
                  (member (car p) '(forall exists) :test #'equal))
           (progn (nsublis `((,(cadr p) . ,(intern (format nil "?X~a" i)))) p)
                  (incf i 1)
                  (push p cf))
           (push p cf)))))
           
(defun variable? (v)
  (and (symbolp v)
       (equal (elt (symbol-name v) 0) #\?)))

(defun preproc (formula)
  (cond 
    ((and (atom formula)
	  (symbolp formula))
     formula)
     ((and (equal (length formula) 3) (equal (car formula) 'equiv))
        (preproc `(and ,(cons 'implies (cdr formula)) ,(cons 'implies (reverse (cdr formula))))))
    ((and (listp formula)
	  (equal (car formula) 'not)
	  (= (length formula) 2))
     (list (car formula) (preproc (cadr formula))))
    ((and (listp formula)
	  (equal (car formula) 'implies)
	  (= (length formula) 3))
     (cons (car formula) (mapcar #'preproc (cdr formula))))
    ((and (listp formula)
	  (member (car formula) '(and or) :test #'equal)
	  (= (length formula) 2))
     (preproc (cadr formula)))
    ((and (listp formula)
	  (member (car formula) '(and or) :test #'equal)
	  (> (length formula) 2))
     (reduce (lambda (x y) (list (car formula) x y))
	     (mapcar #'preproc (cdr formula))))
    ((and (listp formula)
	  (> (length formula) 1)
	  (symbolp (car formula))
	  (every #'variable? (cdr formula)))
     formula)
    (t (error "Invalid Formula ~a" formula))))