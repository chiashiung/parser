---
title: 'parser'
disqus: hackmd
---

Parser
===

## Table of Contents

[TOC]

## LEX,YACC版本

LEX:flex
YACC:bison

## 作業平台

ubuntu 20.04

## 執行方式

1.開啟終端機，至該程式所在檔案
2.輸入make all
3.輸入./compiler <filename
（filename輸入欲測試檔名）
![](https://i.imgur.com/aXdH9Hc.png)

## 如何處理規格書上問題

#### 變數

* linenum:行數
* charnum:當前行的字元數
* befchar:不算出現錯誤的token前的字元數
* scope:
* isdec:判斷該文法是否為宣告
* duplicate:判斷宣告的變數是否重複
* boolexperr:bool expression是否發生錯誤
* errnum:錯誤前的字元（用於boolexperr輸出）
* errword:發生錯誤的token(用於boolexperr輸出)
* msg[256]:正常輸出資訊
* temp[256]:暫存
* dupl[256]:出現重複宣告輸出資訊


#### program

起點為program，由stmts分出多個stmt，stmt可作宣告、class、規格書上6種statements、換行及錯誤回復

```yacc=
program: stmt stmts	
	;

stmts: stmt stmts
	|
	;

stmt: declare
	| classes
	| compond
	| simple
	| conditional
	| loop
	| return
	| methodInvoc
	| NEWLINE
	| error NEWLINE
	;
```

#### 宣告

包括基本型態宣告、矩陣宣告、常數宣告、函數宣告（包含main）

#### class

class藉由fields擴展成多個field，field作宣告、class、建立object、換行及錯誤回復

※讀到classes的｛後scope++,離開｝後scope--（與compond相同）

```yacc=
classes: CLASS ID isline '{' {scope++;} fields '}'{scope--;}

fields: field
	| field fields
	;

field: declare
	| create_obj
	| classes
	| NEWLINE	
	| error NEWLINE
	;
```

#### 6 statements

與規格書大致相似

#### 換行

遇到換行（stmt及field）處理輸出，須檢測是否有出現重複宣告，若有則須額外輸出

※stmt須再檢測bool expression是否有誤，若有處理錯誤資訊輸出（並非在yyerror輸出）

#### 錯誤回復

進yyerror函數，錯誤出現在bool expression不輸出，且依是否為缺少;的錯誤分為兩種輸出

#### symbol table

以二維陣列儲存，第一個維度為scope，第二維度為index，index以雜湊函數計算，雜湊函數為*h(x)=x%256*，以chain處理overflow

## 遇到的問題

* bison與ubuntu版本相容
* 測資main未宣告型態須額外處理
* 測資出現2--不合法的語句須特殊處理
* 文法互相衝突

## 執行結果

#### test1.java

![](https://i.imgur.com/HpoHZyE.png)

#### test2.java

![](https://i.imgur.com/eu1GEpR.png)

#### test3.java

![](https://i.imgur.com/FZrk2N2.png)

#### test4.java

![](https://i.imgur.com/LxoyqmD.png)

#### test5.java

![](https://i.imgur.com/hixsiHv.png)
![](https://i.imgur.com/r9vzYFN.png)

#### test6.java

![](https://i.imgur.com/KXn1uw7.png)
![](https://i.imgur.com/C4qaTgd.png)
