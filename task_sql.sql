-- создаем БД
CREATE DATABASE appfollow; 

-- создаем таблицы
CREATE TABLE appfollow.accounts (
  id INT(5) NOT NULL AUTO_INCREMENT, 
  created DATE, 
  trial_started DATE, 
  trial_ended DATE,
  paid_started DATE, 
  paid_cancelled DATE, 
  PRIMARY KEY(id)
 );

CREATE TABLE appfollow.orders (
  id INT(5) NOT NULL AUTO_INCREMENT, 
  account_id INT(5), 
  amount INT(9), 
  currency CHAR(3), 
  month INT(2), 
  created DATE, 
  PRIMARY KEY (id), 
  FOREIGN KEY (account_id) REFERENCES accounts(id)
 );
 
 --создаем отчет
CREATE TABLE report (
  Month INT(2), 
  Sign_Ups INT(5), 
  Free INT(5), 
  Trial INT(5), 
  Premium INT(5), 
  Premium_Churn INT(5)
 );
 
INSERT INTO report(Month) VALUES (month(now())); -- добавляем текущий месяц

-- вставляем данные в отчет
UPDATE
  report
SET
  --Сколько создано аккаунтов за текущий месяц
  Sign_Ups = (SELECT COUNT(id) FROM accounts WHERE month(created) = month(now())),

  --Сколько создано бесплатных аккаунтов в прошлом месяце
  Free = (SELECT COUNT(id) FROM accounts WHERE date_format(created, '%Y%m') = date_format(date_add(now(), interval -1 month), '%Y%m')),

  --Сколько из них стало триальными в этом месяце
  Trial = (SELECT COUNT(id) FROM accounts WHERE date_format(created, '%Y%m') = date_format(date_add(now(), interval -1 month), '%Y%m')
          AND month(trial_started) = month(now())),

  --Сколько из триальных стало платными в этом месяце
  Premium = (SELECT COUNT(id) FROM accounts WHERE date_format(trial_started, '%Y%m') = date_format(date_add(now(), interval -1 month), '%Y%m')
            AND month(paid_started) = month(now())),

  --Сколько платных было в прошлом месяце, которые отвалились в этом
  Premium_Churn = (SELECT COUNT(id) FROM accounts WHERE date_format(paid_started, '%Y%m') = date_format(date_add(now(), interval -1 month), '%Y%m')
                  AND month(paid_cancelled) = month(now()))
WHERE Month=month(now());

-- Считаем Revenue
SELECT SUM(amount) AS Revenue FROM accounts INNER JOIN orders ON accounts.id = orders.account_id;

-- Считаем MRR
SELECT SUM(amount/month) AS MRR FROM accounts INNER JOIN orders ON accounts.id = orders.account_id;
