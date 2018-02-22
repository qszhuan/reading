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

>**第四诫：**  
>递归时始终要改变至少一个参数。而且这个改变必须是朝着终点越来越近。必须在终止条件中对改变的参数进行测试：当使用cdr时，用null？来检查是不是应该结束。

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

>**第五诫**
>当用+来求值时，要用0作为终止行的值，因为加0不会影响加法的结果。  
>当用x来求值时，要用1作为终止行的值，因为乘以1不会影响乘法的结果。  
>当用cons求值时，要用()作为终止行的值。

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

>**第四诫（最终版）**  
>递归时要始终改变至少一个参数。当递归一个atom的列表lat时，用(cdr lat)。当递归一个数字n时，使用(sub1 n)。当递归一个S-表达式列表l时，如果(null? l)和(atom? (car l)) 都不为true，使用(car l)和(cdr l)。
参数必须是朝着递归终止的方向改变。需要在终止条件中对参数进行测试：
>
>当使用cdr时，检查是否以null?结束；  
>当使用sub1时，检查是否以zero?结束。


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

>**第六诫**  
>仅当功能正确之后再进行简化

#### 第六章 影子

这一章主要讲算术。

本章算术的定义：算术表达式是一个atom（包括数字），或者用+，x或↑连接的两个算术表达式。

>**第七诫**  
>在subparts上递归有着相同的特性：
>
>* 在list的子列表上
>* 在算术表达式的子表达式上

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

>**第八诫**  
>使用辅助函数对表现形式进行抽象

>**第九诫**  
>把相同的模式抽象成函数

{% highlight scheme %}
;difficult...

(define multirember&co
    (lambda (a lat col)
        (cond
            ( 
                (null? lat) 
                (col (quote ()) (quote ()))
            )
            (
                (eq? (car lat) a)
                (multirember&co 
                    a (cdr lat)
                    (lambda (newlat seen)
                        (col newlat
                            (cons (car lat) seen)
                        )
                    )
                )
            )
            (
                else
                (multirember&co
                    a (cdr lat)
                    (lambda (newlat seen)
                        (col 
                            (cons (car lat) newlat)
                            seen
                        )
                    )
                )

            )
        )
    )
)


(define a-friend
    (lambda (x y)
        (null? y)
    )
)

; What's the value (multirember&co a lat col)
; Where 
; a is tuna
; lat is ()
; col is a-friend
;; The result is #t


; What's the value (multirember&co a lat col)
; Where 
; a is tuna
; lat is (tuna)
; col is a-friend

;; define the new collector

(define new-friend
    (lambda (newlat seen)
        (col 
            newlat
            (cons (car lat) seen)
        )
    )
)

;; It asnsers #f, as the second arg for a-friend is (cons (quote tuna) (quote ())), which is not null.


; What's the value (multirember&co a lat col)
; Where 
; a is tuna
; lat is (and tuna)
; col is a-friend
;; this time, it will run to the third case in cond

; Define the new collector

(define lastest-friend
    (lambda (newlat seen)
        (a-friend
            (cons (quote and) newlat)
            seen
        )
    )
)
;; so the result if #f, as it will be (a-friend (and) (tuna))

{% endhighlight %}

> What does (multirember&co a lat f) do?

> It looks at every atom of the lat to see whether it is eq? to a.
>
> Those atoms that are not are collected in one list ls1;
>
> the others for which the answer is true are collected in a second list Is2.
>
> Finally, it determines the value of (f ls1 ls2).

{% highlight scheme %}
;Final question: What is the value of
;(multirember&co (quote tuna) Is col)
;where
;ls is (strawberries tuna and swordfish)
;and
;col is
(define last-friend
(lambda (x y)
(length x)))

{% endhighlight %}

>**第十诫**  
>创建函数来一次收集多个值


{% highlight scheme %}
(define multiinsertL
    (lambda (new old lat)
        ( (null? lat) (quote()))
        ( 
            (eq? (car lat) old)
            (cons new
                (cons 
                    old
                    (multiinsertL new old (cdr lat))
                )
            )
        )
        ( 
            (else
                (cons 
                    (car lat)
                    (multiinsertL new old (cdr lat))
                )
            )
        )
    )
)

(define multiinsertR
    (lambda (new old lat)
        ((null? lat) (quote()))
        ( 
            (eq? old (car lat))
            (cons 
                (car lat)
                (cons 
                    new 
                    (multiinsertR new old (cdr lat))
                )
            )
        )
        (   
            else
            (cons
                (car lat)
                (multiinsertR new old (cdr lat))
            )
        )
    )
)
{% endhighlight %}

{% highlight scheme %}
(define multiinsertLR
    (lambda (new oldL oldR lat)
        ( (null? lat) (quote()))
        ( 
            (eq? (car lat) oldL)
            (cons 
                new 
                (cons
                    oldL
                    (multiinsertLR new oldL oldR (cdr lat))
                )
            )
        )
        (
            (eq? (car lat) oldR)
            (cons
                oldR
                (cons
                    new
                    (multiinsertLR new oldL oldR (cdr lat))
                )
            )
        )
        (else
            (cons
                (car lat)
                (multiinsertLR new oldL oldR (cdr lat))
            )
        )
    )
)
{% endhighlight %}

下面实现multiinsetLR&co：

{% highlight scheme %}

(define multiinsertLR&co
    (lambda (new oldL oldR lat col)
        (cond
            ; 问题1: lat是否为空
            ( 
                (null? lat) 
                (col (quote ()) 0 0)
            )
            ; 问题2：(car lat) 是否等于 oldL
            (
                (eq? (car lat) oldL)
                (multiinsertLR&co 
                    new oldL oldR (cdr lat)
                    (lambda (newlat L R)
                        (col 
                            (cons new (cons oldL newlat))
                            (add1 L) R
                        )
                    )

                )
            )
            ; 问题3：(car lat)是否等于 oldR
            (
                (eq? (car lat) oldR)
                (multiinsertLR&co
                    new oldL oldR (cdr lat)
                    (lambda (newlat L R)
                        (col 
                            (cons oldR (cons new newlat))
                            L (add1 R)
                        )
                    )
                )
            )
            ; 问题4： else
            ( else
                (multiinsertLR&co
                    new oldL oldR (cdr lat)
                    (lambda (newlat L R)
                        (col 
                            (cons (car lat) newlat)
                            L R
                        )
                    )
                )
            )
        )
    )
)

; (multiinsertLR&co new oldL oldR lat col)
; 当 new = salty
; oldL = fish
; oldR = chips
; lat = (chips and fish or fish and chips)

; 结果是 (col newlat 2 2),
; newlat = (chips salty and salty fish or salty fish and chips salty)

{% endhighlight %}

实现even-only*
{% highlight scheme %}
;首先是even
(define even?
    (lambda (n)
        (= (x (/ n 2) 2) n)
    )
)
; even-only*
(define even-only*
    (lambda (l)
        (cond
            ; null? 
            (
                (null? l)
                (quote ())
            )
            ; atom?
            (
                (atom? (car l))
                (cond
                   ( 
                       (even? (car l)) 
                       (cons 
                            (car l)
                            (even-only* (cdr l))
                       )
                   )
                   (else
                        (even-only* (cdr l))
                   )
                )
            )
            ; else
            (else
                (cons
                    (even-only* (car l))
                    (even-only* (cdr l))
                )
            )
        )
    )
)
; even-only*&co
; Can you write the function evens-only*&co
; It builds a nested list of even numbers by
; removing the odd ones from its argument
; and simultaneously multiplies the even
; numbers and sums up the odd numbers that
; occur in its argument.

(define even-only*&co
    (lambda (l col)
        (cond
            ;null?
            ( 
                (null? l) 
                (col (quote ()) 1 0) ;第一个参数用来存放结果，第二个存放偶数的乘积，第三个存放奇数和
            )
            ; atom?
            (   
                (atom? (car l))
                (cond
                    (
                        (even? (car l))
                        (even-only*&co
                            (cdr l)
                            (lambda (newl L R)
                                (col
                                    (cons (car l) newl)
                                    (* (car l) L)
                                    R
                                )
                            )
                        )
                    )
                    (else
                        (even-only*&co
                            (cdr l)
                            (lambda (newl L R)
                                (col 
                                    newl
                                    L
                                    (+ R (car l))
                                )
                            )
                        )
                    )
                )
            )
            ; else
            (else
                (even-only*&co
                    (car l)
                    (lambda (al aL aR)
                        (even-only*&co
                            (cdr l)
                            (lambda (dl dL dR)
                                (col 
                                    (cons al dl)
                                    (* aL dL)
                                    (+ aR dR)
                                )
                            
                            )
                        )
                    )
                )
            )
        )
    )
)
{% endhighlight %}


### 第九章

以一个有趣的游戏开始：

假设 a = caviar，lat = (6 2 4 caviar 5 7 3)，有(looking a lat) = #t;

假设 a = caviar，lat = (6 2 grits caviar 5 7 3)，有(looking a lat) = #f;

(looking a lat)，每个数字是下一个寻找的位置的下标。

{% highlight scheme %}

(define looking 
    (lambda (a lat)
        (keep-looking a (pick 1 lat) lat)
    )
)

;没有在lat的子集上进行迭代，叫做"unnatural"迭代
;如何保证迭代终止？
;换句话说，终止条件是什么
(define  keep-looking
    (lambda (a sorn lat)
        (cond
            (
                (number? sorn)
                (keep-looking a (pick sorn lat) lat)
            )
            (else
                (eq? sorn a)
            )
        )
        
    )
)
; looking是偏函数

(define pick
    (lambda (n lat)
        (cond
            ( 
                (= 1 n)
                (car lat)
            )
            (else
                (pick (sub1 n) (cdr lat))
            )
        )
    )
)
{% endhighlight %}



