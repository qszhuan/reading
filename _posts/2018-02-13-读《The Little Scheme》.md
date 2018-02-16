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

##### 第四诫：
Always change at least one argument while recurring. It
must be changed to be closer to termination. The changing
argument must be tested in the termination condition:
when using cdr, test termination with null?

#### 数字游戏

关于数字的操作，和atom是相似的，在处理时要明确终止条件-terminal condition，如zero? n，再者要寻找natural recursion。

{% highlight scheme %}
(define addtup
    (lambda (tup)
        (cond
            ((null? tup) 0)
            (else (+ (car tup) (addtup (cdr tup))))
        )
    )
)

(define *
    (lambda (n m)
        (cond
            ((zero? m) 0)
            (else (+ n (* n (sub1 m))))
        )
    )
)
; 对于上述命令(* n m)的natural recursion是 (* n (sub1 m))
{% endhighlight %}

##### 第五诫
当用+来求值时，要用0作为终止行的值，因为加0不会影响加法的结果。
当用x来求值时，要用1作为终止行的值，因为乘以1不会影响乘法的结果。
当用cons求值时，要用()作为终止行的值。

{% highlight scheme %}
(define tup+
    (lambda (tup1 tup2)
        (cond
            ( (and (null? tup1) (null? tup2)) (quote()) )
            ( else 
                    (cons 
                        (+ (car tup1) (car tup2))
                        (tup+ (cdr tup1) (cdr tup2))
                    )
            )
        )
    )
)
; 对于上述命令(* n m)的natural recursion是 (tup+ (cdr tup1) (cdr tup2))
; 如果想处理两个不同大小的tuple，需要在终止条件增加两个问题

(define tup+
    (lambda (tup1 tup2)
        (cond
            ( (null? tup1) tup2)
            ( (null? tup2) tup1)
            ( else 
                    (cons 
                        (+ (car tup1) (car tup2))
                        (tup+ (cdr tup1) (cdr tup2))
                    )
            )
        )
    )
)
{% endhighlight %}

再来看比较:
{% highlight scheme %}
;终止条件是某一个值递减为0

(define >
    (lambda (n m)
        (cond
            ( (zero? n) #f) ; 这两行的顺序不能替换
            ( (zero? m) #t) ; 因为该行意味着 n > 0 and m = 0
            ( else (> (sub1 n) (sub1 m)))
        )
    )
)

(define <
    (lambda (n m)
        (cond
            ( (zero? m) #f)
            ( (zero? n) #t)
            ( else (< (sub1 n) (sub1 m)))
        )
    )
)

(define =
    (lambda (n m)
        (cond
            ((> n m) #f)
            ((< n m) #f)
            (else #t)
        )
    )
)
{% endhighlight %}


再来看幂运算:

{% highlight scheme %}

;(↑ 2 3) = 8
(define ↑
    (lambda (n m)
        (cond
            ( (zero? m) 1)
            (else (* n (↑ n sub1(m))))
        )
    )
)
{% endhighlight %}

#### 第五章 全是小星星

这可以理解为多维递归，如从(abc def (abc def) (abc (abc de)))中去掉所有abc后为(def (def) ((de)))

