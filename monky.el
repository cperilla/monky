;;; monky.el -- control Hg from Emacs.

;; Copyright (C) 2011 Anantha Kumaran.

;; Author: Anantha kumaran <ananthakumaran@gmail.com>
;; Keywords: tools

;; Monky is free software: you can redistribute it and/or modify it
;; under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; Monky is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:


;;; Code:

(defgroup monky nil
  "Controlling Hg from Emacs."
  :prefix "monky-"
  :group 'tools)

(defcustom monky-hg-executable "hg"
  "The name of the Hg executable."
  :group 'monky
  :type 'string)

(defcustom monky-hg-standard-options '("--pager=no")
  "Standard options when running Hg."
  :group 'monky
  :type '(repeat string))

;; TODO
(defcustom monky-save-some-buffers t
  "Non-nil means that \\[monky-status] will save modified buffers before running.
Setting this to t will ask which buffers to save, setting it to 'dontask will
save all modified buffers without asking."
  :group 'monky
  :type '(choice (const :tag "Never" nil)
		 (const :tag "Ask" t)
		 (const :tag "Save without asking" dontask)))

;; TODO
(defcustom monky-revert-item-confirm t
  "Require acknowledgment before reverting an item."
  :group 'monky
  :type 'boolean)


(defgroup monky-faces nil
  "Customize the appearance of Monky"
  :prefix "monky-"
  :group 'faces
  :group 'monky)

(defface monky-header
  '((t))
  "Face for generic header lines.

Many Monky faces inherit from this one by default."
  :group 'monky-faces)

(defface monky-section-title
  '((t :weight bold :inherit monky-header))
  "Face for section titles."
  :group 'monky-faces)

(defface monky-branch
  '((t :weight bold :inherit monky-header))
  "Face for the current branch."
  :group 'monky-faces)

(defface monky-diff-file-header
  '((t :inherit monky-header))
  "Face for diff file header lines."
  :group 'monky-faces)

(defface monky-diff-hunk-header
  '((t :slant italic :inherit monky-header))
  "Face for diff hunk header lines."
  :group 'monky-faces)

(defface monky-diff-add
  '((((class color) (background light))
     :foreground "blue1")
    (((class color) (background dark))
     :foreground "white"))
  "Face for lines in a diff that have been added."
  :group 'monky-faces)

(defface monky-diff-none
  '((t))
  "Face for lines in a diff that are unchanged."
  :group 'monky-faces)

(defface monky-diff-del
  '((((class color) (background light))
     :foreground "red")
    (((class color) (background dark))
     :foreground "OrangeRed"))
  "Face for lines in a diff that have been deleted."
  :group 'monky-faces)

(defface monky-log-graph
  '((((class color) (background light))
     :foreground "grey11")
    (((class color) (background dark))
     :foreground "grey80"))
  "Face for the graph element of the log output."
  :group 'monky-faces)

(defface monky-log-sha1
  '((((class color) (background light))
     :foreground "firebrick")
    (((class color) (background dark))
     :foreground "tomato"))
  "Face for the sha1 element of the log output."
  :group 'monky-faces)

(defface monky-log-message
  '((t))
  "Face for the message element of the log output."
  :group 'monky-faces)

(defface monky-item-highlight
  '((((class color) (background light))
     :background "gray95")
    (((class color) (background dark))
     :background "dim gray"))
  "Face for highlighting the current item."
  :group 'monky-faces)

(defface monky-item-mark
  '((((class color) (background light))
     :foreground "red")
    (((class color) (background dark))
     :foreground "orange"))
  "Face for highlighting marked item."
  :group 'monky-faces)

(defface monky-log-tag-label
  '((((class color) (background light))
     :background "LightGoldenRod")
    (((class color) (background dark))
     :background "DarkGoldenRod"))
  "Face for hg tag labels shown in log buffer."
  :group 'monky-faces)

(defface monky-log-head-label-bisect-good
  '((((class color) (background light))
     :box t
     :background "light green"
     :foreground "dark olive green")
    (((class color) (background dark))
     :box t
     :background "light green"
     :foreground "dark olive green"))
  "Face for good bisect refs"
  :group 'monky-faces)

(defface monky-log-head-label-bisect-bad
  '((((class color) (background light))
     :box t
     :background "IndianRed1"
     :foreground "IndianRed4")
    (((class color) (background dark))
     :box t
     :background "IndianRed1"
     :foreground "IndianRed4"))
  "Face for bad bisect refs"
  :group 'monky-faces)

(defface monky-log-head-label-remote
  '((((class color) (background light))
     :box t
     :background "Grey85"
     :foreground "OliveDrab4")
    (((class color) (background dark))
     :box t
     :background "Grey11"
     :foreground "DarkSeaGreen2"))
  "Face for remote branch head labels shown in log buffer."
  :group 'monky-faces)

(defface monky-log-head-label-tags
  '((((class color) (background light))
     :box t
     :background "LemonChiffon1"
     :foreground "goldenrod4")
    (((class color) (background dark))
     :box t
     :background "LemonChiffon1"
     :foreground "goldenrod4"))
  "Face for tag labels shown in log buffer."
  :group 'monky-faces)

(defface monky-log-head-label-patches
  '((((class color) (background light))
     :box t
     :background "IndianRed1"
     :foreground "IndianRed4")
    (((class color) (background dark))
     :box t
     :background "IndianRed1"
     :foreground "IndianRed4"))
  "Face for Stacked Hg patches"
  :group 'monky-faces)


(defface monky-log-head-label-local
  '((((class color) (background light))
     :box t
     :background "Grey85"
     :foreground "LightSkyBlue4")
    (((class color) (background dark))
     :box t
     :background "Grey13"
     :foreground "LightSkyBlue1"))
  "Face for local branch head labels shown in log buffer."
  :group 'monky-faces)

(defface monky-log-head-label-default
  '((((class color) (background light))
     :box t
     :background "Grey50")
    (((class color) (background dark))
     :box t
     :background "Grey50"))
  "Face for unknown ref labels shown in log buffer."
  :group 'monky-faces)

(defface monky-menu-selected-option
  '((((class color) (background light))
     :foreground "red")
    (((class color) (background dark))
     :foreground "orange"))
  "Face for selected options on monky's menu"
  :group 'monky-faces)


(setq monky-hg-executable "hg")

(setq monky-top-section nil)
(make-variable-buffer-local 'monky-top-section)

(defstruct monky-section
  parent children beginning end type title hidden info
  needs-refresh-on-show)

(defun monky-set-section-info (info &optional section)
  (setf (monky-section-info (or section monky-top-section)) info))

(setq monky-section-hidden-default nil)

(defun monky-new-section (title type)
  "Create a new section with title TITLE and type TYPE in current buffer.

If not `monky-top-section' exist, the new section will be the new top-section
otherwise, the new-section will be a child of the current top-section.

If TYPE is nil, the section won't be highlighted."
  (let* ((s (make-monky-section :parent monky-top-section
				:title title
				:type type
				:hidden monky-section-hidden-default)))
    (if monky-top-section
	(push s (monky-section-children monky-top-section))
	(setq monky-top-section s))
    s))

(defmacro monky-with-section (title type &rest body)
  (declare (indent 2))
  "doc."
  (let ((s (make-symbol "*section*")))
    `(let* ((,s (monky-new-section ,title ,type))
	    (monky-top-section ,s))
       (setf (monky-section-beginning ,s) (point))
       ,@body
       (setf (monky-section-end ,s) (point))
       (setf (monky-section-children ,s)
	     (nreverse (monky-section-children ,s))))))

(defmacro monky-create-buffer-sections (&rest body)
  "Empty current buffer of text and monky's section, and then evaluate BODY."
  (declare (indent 0))
  `(let ((inhibit-read-only t))
     (erase-buffer)
     (let ((monky-old-top-section monky-top-section))
       (setq monky-top-section nil)
       ,@body
       (when (null monky-top-section)
	 (monky-with-section 'top nil
			     (insert "(empty)\n")))
       (monky-propertize-section monky-top-section))))

(defun monky-propertize-section (section)
  "Add text-property needed for SECTION."
  (put-text-property (monky-section-beginning section)
		     (monky-section-end section)
		     'monky-section section)
  (dolist (s (monky-section-children section))
    (monky-propertize-section s)))

(defun monky-insert-section (type title buffer-title washer cmd &rest args)
  (let* ((section (monky-with-section title type
		    (if buffer-title
			(insert (propertize buffer-title 'face 'monky-section-title) "\n"))
		    (setq body-beg (point))
		    (apply 'process-file cmd nil t nil args)
		    (if (not (eq (char-before) ?\n))
			(insert "\n"))
		    (if washer
			(save-restriction
			  (narrow-to-region body-beg (point))
			  (goto-char (point-min))
			  (funcall washer)
			  (goto-char (point-max)))))))
    (if (= body-beg (point))
	(monky-cancel-section section)
      (insert "\n"))
    section))

(defun monky-cancel-section (section)
  (delete-region (monky-section-beginning section)
		 (monky-section-end section))
  (let ((parent (monky-section-parent section)))
    (if parent
	(setf (monky-section-children parent)
	      (delq section (monky-section-children parent)))
      (setq monky-top-section nil))))

(defun monky-current-section ()
  "Return the monky section at point."
  (or (get-text-property (point) 'monky-section)
      monky-top-section))

(defun monky-section-context-type (section)
  (if (null section)
      '()
    (let ((c (or (monky-section-type section)
		 (if (symbolp (monky-section-title section))
		     (monky-section-title section)))))
      (if c
	  (cons c (monky-section-context-type
		   (monky-section-parent section)))
	'()))))

(defun monky-prefix-p (prefix list)
  "Returns non-nil if PREFIX is a prefix of LIST.  PREFIX and LIST should both be
lists.

If the car of PREFIX is the symbol '*, then return non-nil if the cdr of PREFIX
is a sublist of LIST (as if '* matched zero or more arbitrary elements of LIST)"
  (or (null prefix)
      (if (eq (car prefix) '*)
          (or (monky-prefix-p (cdr prefix) list)
              (and (not (null list))
                   (monky-prefix-p prefix (cdr list))))
        (and (not (null list))
             (equal (car prefix) (car list))
             (monky-prefix-p (cdr prefix) (cdr list))))))

(defun monky-hg-section (type title buffer-title washer &rest args)
  (apply #'monky-insert-section
	 type
	 title
	 buffer-title
	 washer
	 monky-hg-executable
	 (append monky-hg-standard-options args)))

(defun monky-wash-sequence (func)
  "Run FUNC until end of buffer is reached

FUNC should leave point at the end of the modified region"
  (while (and (not (eobp))
	      (funcall func))))

(setq monky-process nil)
(setq monky-process-buffer-name "*monky-process")

(defmacro monky-section-action (head &rest clauses)
  (declare (indent 1))
  `(monky-section-case ,head ,@clauses))

(defmacro monky-section-case (head &rest clauses)
  "Make different action depending of current section.

HEAD is (SECTION INFO &optional OPNAME),
  SECTION will be bind to the current section,
  INFO will be bind to the info's of the current section,
  OPNAME is a string that will be used to describe current action,

CLAUSES is a list of CLAUSE, each clause is (SECTION-TYPE &BODY)
where SECTION-TYPE describe section where BODY will be run.

This returns non-nil if some section matches. If the
corresponding body return a non-nil value, it is returned,
otherwise it return t.

If no section matches, this returns nil if no OPNAME was given
and throws an error otherwise."

(declare (indent 1))
(let ((section (car head))
      (info (cadr head))
      (type (make-symbol "*type*"))
      (context (make-symbol "*context*"))
      (opname (caddr head)))
  `(let* ((,section (monky-current-section))
	  (,info (monky-section-info ,section))
	  (,type (monky-section-type ,section))
	  (,context (monky-section-context-type ,section)))
     (cond ,@(mapcar (lambda (clause)
		       (let ((prefix (car clause))
			     (body (cdr clause)))
			 `(,(if (eq prefix t)
				`t
			      `(monky-prefix-p ',(reverse prefix) ,context))
			   (or (progn ,@body)
			       t))))
		     clauses)
	   ,@(when opname
	       `(((not ,type)
		  (error "Nothing to %s here" ,opname))
		 (t
		  (error "Can't %s as %s"
			 ,opname
			 ,type))))))))

;; monky mode

(defun monky-mode ()
  (kill-all-local-variables)
  (buffer-disable-undo)
  (setq buffer-read-only t)
  (setq major-mode 'monky-mode
	mode-name "Monky"
	mode-line-process ""
	truncate-lines t)
  (use-local-map monky-mode-map))

(defun monky-mode-init (dir submode refresh-func &rest refresh-args)
  (setq default-directory dir
	monky-submode submode
	monky-refresh-function refresh-func
	monky-refresh-args refresh-args)
  (monky-mode)
  (monky-refresh-buffer))

(defun monky-refresh-buffer (&optional buffer)
  (with-current-buffer (or buffer (current-buffer))
    (if monky-refresh-function
	(apply monky-refresh-function
	       monky-refresh-args))))

;; utils

(defun monky-trim-line (str)
  (if (string= str "")
      nil
    (if (equal (elt str (- (length str) 1)) ?\n)
	(substring str 0 (- (length str) 1))
      str)))

(defun monky-hg-shell (args)
  (apply #'process-file
	 monky-hg-executable
	 nil (list t nil) nil
	 (append monky-hg-standard-options args)))

(defun monky-hg-output (args)
  (with-output-to-string
    (with-current-buffer standard-output
      (monky-hg-shell args))))

(defun monky-hg-string (&rest args)
  (monky-trim-line (monky-hg-output args)))


(defun monky-get-root-dir ()
  (let ((root (monky-hg-string "root")))
    (if root
	(concat root "/")
      (error "Not inside a hg repo"))))



(defun monky-find-buffer (submode &optional dir)
  (let ((rootdir (or dir (monky-get-root-dir))))
    (find-if (lambda (buf)
	       (with-current-buffer buf
		 (and default-directory
		      (equal (expand-file-name default-directory) rootdir)
		      (eq major-mode 'monky-mode)
		      (eq monky-submode submode)
		      )))
	     (buffer-list))))

(defun monkey-refresh-status ()
  (monky-create-buffer-sections
    (monky-with-section 'status nil
      (monky-insert-untracked-files))))


;;; Untracked files

(defun monky-wash-untracked-file ()
  (if (looking-at "^? \\(.*\\)$")
      (let ((file (match-string-no-properties 1)))
	(delete-region (point) (+ (line-end-position) 1))
	(monky-with-section file 'file
	  (monky-set-section-info file)
	  (insert "\t" file "\n"))
	t)
    nil))

(defun monky-insert-untracked-files ()
  (apply 'monky-hg-section
	 '(untracked
	   nil
	   "Untracked files:"
	   (lambda ()
	     (monky-wash-sequence #'monky-wash-untracked-file))
	   "status" "-u")))

(defun monky-visit-item (&optional other-window)
  "Visit current item.
With a prefix argument, visit in other window."
  (interactive (list current-prefix-arg))
  (monky-section-action (item info "visit")
    ((untracked file)
     (funcall (if other-window 'find-file-other-window 'find-file)
	      info))))

(setq monky-status-mode-map
      (let ((map (make-keymap)))
	map))

(define-minor-mode monky-status-mode
  "Minor mode for hg status."
  :group monky
  :init-value ()
  :lighter "status"
  :keymap monky-status-mode-map)

(defun monky-status ()
  (interactive)
  (let* ((rootdir (monky-get-root-dir))
	 (buf (or (monky-find-buffer 'status rootdir)
		  (generate-new-buffer
		   (concat "*monky: "
			   (file-name-nondirectory
			    (directory-file-name rootdir)) "*")))))
    (pop-to-buffer buf)
    (monky-mode-init rootdir 'status #'monkey-refresh-status)
    (monky-status-mode t)))

(setq monky-mode-map
      (let ((map (make-keymap)))
	(suppress-keymap map t)
	(define-key map (kbd "RET") 'monky-visit-item)
	map))

(setq default-directory "/home/ananth/monky/")
