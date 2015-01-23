# Hangman

## Environment

 1. mysql `5.6.22`
 2. ruby `2.0.0p481`
 3. bundle `1.7.11`

## How to Run

 1. copy `configs/config.yml.template` to `configs/config.yml` and config
 2. `bundle install` to install required gems
 3. `ruby init_data.rb` to init data
 4. `ruby play_game.rb` to start game

## Prepare Data

### Store Words Database

 1. Download words from
    http://www-personal.umich.edu/~jlawler/wordlist
    https://raw.githubusercontent.com/eneko/data-repository/master/data/words.txt

 2. Insert words into db, while I find too much records of short words(length less than 5) will decress the score, so find a tiny wordlist for the words length less than 5

 3. Store word in database with schema:

```
word:
    word: xxxxx
    length: 5
    wight: default 1
```

### Slice Words

 1. Slice words by length and count letter groups frequency

### Reverse Words Compare

TODO

## Thought

 1. Select largest count letter in words_slice tables by word length
 2. If response like `**E*A*`, replace `*` with `.`(eg: `..E.A.`) and use mysql regexp select from db, then count the match words' next max count letter
 3. Limit max guess to 7, because word bank not quite match, too much wrong guess decress scores.
 4. *TODO:* Compare letter groups in words_slice and find out a better way to match letter.
 5. *TODO:* Got more reliable words data
 

## Got Issues and Solution

ubuntu14.04
error:
```
ERROR:  Error installing mysql2:
    ERROR: Failed to build gem native extension.
```
Solution:
sudo apt-get install libmysqlclient-dev
