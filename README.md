# spendy-reporting

To run locally in docker container:
1. ```docker build . -t spendy-reporting```
2. ```docker run -p 8080:8080 spendy-reporting```

Check status
http://localhost:8080/

Get spend report by category
http://localhost:8080/spend_by_category?user_name={user_name}

Get spend report by day
http://localhost:8080/spend_by_day?user_name={user_name}
