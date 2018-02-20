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

目前看到了第三章，学习到了十诫中的第一条的list部分：列表递归时要问两个问题：列表是不是为空？还是其他？

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
递归时始终要改变至少一个参数。而且这个改变必须是朝着终点越来越近。必须在终止条件中对改变的参数进行测试：当使用cdr时，用null？来检查是不是应该结束。

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

这可以理解为多维递归，如从(abc def (abc def) (abc (abc de)))中去掉所有abc后为(def (def) ((de)))。

#####第四诫（最终版）

递归时要始终改变至少一个参数。当递归一个atom的列表lat时，用(cdr lat)。当递归一个数字n时，使用(sub1 n)。当递归一个S-表达式列表l时，如果(null? l)和(atom? (car l)) 都不为true，使用(car l)和(cdr l)。
参数必须是朝着递归终止的方向改变。需要在终止条件中对参数进行测试：

当使用cdr时，检查是否以null?结束；
当使用sub1时，检查是否以zero?结束。


{% highlight scheme %}
(define occur*
    (lambda (a l)
        (cond
            ((null? l) 0)
            ( (atom? (car l)) (cond
                                ((eq? (car l) a) (add1 (occur* a (cdr l))))
                                (else (occur* a (cdr l)))
                              )
            )
            (else (+ (occur* a (car l)) 
                     (occur* a (cdr l))))
        )
    )
)

(define subst*
    (lambda (new old l)
        ((null? l) (quote()))
        ((atom? (car l)) 
         (cond
            ((eq? (car l) old) 
             (cons 
               new 
               (subst* new old (cdr l))
             )
            (else 
             (cons 
                (car l) 
                (subst* new old (cdr l))
             )
            )
         )
        )
        (else (cons 
                (subst* new old (car l))
                (subst* new old (cdr l))
              )
        )
    )
)

(define insertL*
    (lambda (new old l)
        ((null? l) (quote()))
        ((atom? (car l))
         (cond
            ((eq? (car l) old) 
             (cons 
                new 
                (cons old (insertL* new old (cdr l)))
             )
            )
            (else (cons 
                    (car l) 
                    (insertL* new old (cdr l)))
            )
         )
        )
        (else (cons 
                (insertL* new old (car l))
                (insertL* new old (cdr l))
              )
        )
    )
)
{% endhighlight %}

#####第六诫
仅当功能正确之后再进行简化

####第六章 影子
这一章主要讲算术。

本章算术的定义：算术表达式是一个atom（包括数字），或者用+，x或↑连接的两个算术表达式。

##### 第七诫
在subparts上递归有着相同的特性：

* 在list的子列表上
* 在算术表达式的子表达式上

{% highlight scheme %}
;求表达式的值 
; (1 + 2)
; (1 + (2 x 3))
(define value
    (lambda (nexp)
        (cond
            ( (atom? nexp) nexp)
            ( (eq? (car (cdr nexp)) (quote +))
                (+ (value (car nexp))
                    (value (car (cdr (cdr nexp))))
                )
            )
            ( (eq? (car (cdr nexp)) (quote x))
                (x (value (car nexp))
                    (value (car (cdr (cdr nexp))))
                )
            )
            ( else 
                (↑ (value (car nexp))
                    (value (car (cdr (cdr nexp))))
                )
            )
        )
    )
;当表达式的形式改变后
;如(+ 1 3)
;情况会稍微复杂些，因为(cdr (cdr l))是(3)而不是3
;这时候，可以写一些辅助函数隐藏掉这些细节

{% endhighlight %}

#####第八诫
使用辅助函数对表现形式进行抽象




