---
title: 读《The Little Scheme》 
category:  
tags: [阅读]  
layout: post  
author:  Daniel P. Friedman and Matthias Felleisen
name: 
thumbnail: /assets/images/books/The Little Scheme.jpg
---

十分庆幸我偶然找到这本书，内容真是精彩，从来没有一本书这么吸引人，忽然感觉LISP的（（（（））））也没有那么讨厌了:)

目前看到了第三章，学习到了十诫中的第一条的list部分：循环列表时要问两个问题：列表是不是为空？还是其他？

五条法则都已经有了接触：
1. The Law of Car 
2. The Law of Cdr
3. The Law of Cons
4. The Law of Null?
5. The Law of Eq?


{% highlight scheme %}
(define subst2
    (lambda (new o1 o2 lat)
        (cond
        ((null? lat) (quote()))
        (else (cond
                ((eq? (car lat) o1) cons(new (cdr lat)))
                ((eq? (car lat) o2) cons(new (cdr lat)))
                (else cons((car lat) subst2(new o1 o2 (cdr lat))))
)))))

; 用or替换两个eq?
((or (eq? (car lat) o1) (eq? (car lat) o2)) (cons new (cdr lat)))


(define multirember
    (lambda (a lat)
        (cond
        ((null? lat) (quote()))
        (else (cond
                ((eq? (car lat)) (multirember a (cdr lat)))
                (else (cons (car lat) (multirember a (cdr lat))))
        )))
        )
    )

(define multiinsertR
    (lambda (new old lat)
        (cond
            ((null? lat) (quote()))
            (else (cond
                    ((eq? (car lat) old) (cons old (cons new (multiinsertR new old (cdr lat)))))
                    (else (cons (car lat) (multiinsertR new old (cdr lat))))
                )
        )
    )
)

(define multiinsertL
    (lambda (new old lat)
        (cond
            ((null? lat) (quote()))
            (else 
                (cond
                    ((eq? (car lat) old) (cons new (cons old (multiinsertL new old (cdr lat)))))
                    (else (cons (car lat) (multiinsertL new old (cdr lat))))
                )
            )
        )
    )
)

(define multisubst
    (lambda (new old lat)
        (cond 
            ((null? lat) (quote()))
            (else 
                (cond
                    ((eq? (car lat) old) (cons new (multisubst new old (cdr lat))))
                    (else (cons (car lat) (multisubst new old (cdr lat))))
                )
            )
        )
    )
)
{% endhighlight %}

#### 第四诫：
Always change at least one argument while recurring. It
must be changed to be closer to termination. The changing
argument must be tested in the termination condition:
when using cdr, test termination with null?