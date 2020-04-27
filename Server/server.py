"""This server API is written by probhakar for edge analytics project
    12th March for the project COVID-REPORTER"""


# importing system related libraries
import os
import time
from datetime import datetime
# changing the system timestamp to kolkata
os.environ["TZ"] =  'Asia/Kolkata'
time.tzset()

# importing flask and flask restful for creation of the APIs
from flask import Flask, jsonify, request
from flask_restful import Resource, Api, reqparse

# importing libraries for crytography
from Crypto.Cipher import AES
from Crypto.Util.Padding import pad, unpad
import random, string
import base64

# defining helper function for cryptography
BLOCK_SIZE = 32 # Bytes

def get_16_len_string():
    x = ''.join(random.choices(string.ascii_letters + string.digits, k=16))
    return x
def encrypt_message(message):
    key = "gfDeanTy6%43Bja8".encode("utf-8")
    cipher = AES.new(key, AES.MODE_ECB)
    return (base64.b64encode(cipher.encrypt(pad(message.encode("utf-8"), BLOCK_SIZE)))).decode()

def decrypt_message(encrypted_message):
    key = "gfDeanTy6%43Bja8"
    decipher = AES.new(key.encode("utf-8"), AES.MODE_ECB)
    return (unpad(decipher.decrypt(base64.b64decode(encrypted_message)), BLOCK_SIZE)).decode()

def get_unique_id(lat = 28.4999233, lon = 77.0682333, age_lower = 30 , age_upper = 40, gender = "M"):
    unique_id = get_16_len_string() + "$" + str(lat) +"$" + str(lon) + "$" + str(age_lower) + "$" + str(age_upper) + "$" + gender
    return unique_id


# method for calculating haversine distance
from math import radians, cos, sin, asin, sqrt

def haversine(lat1, lon1, lat2, lon2): # output will be in meters
    """
    Calculate the great circle distance between two points
    on the earth (specified in decimal degrees)
    """
    # convert decimal degrees to radians
    lon1, lat1, lon2, lat2 = map(radians, [lon1, lat1, lon2, lat2])

    # haversine formula
    dlon = lon2 - lon1
    dlat = lat2 - lat1
    a = sin(dlat/2)**2 + cos(lat1) * cos(lat2) * sin(dlon/2)**2
    c = 2 * asin(sqrt(a))
    r = 6371 # Radius of earth in kilometers. Use 3956 for miles
    return c * r * 1000


# creating flask app and api instances
app = Flask(__name__)
api = Api(app)

# importing library for accessing SQL database
from flask_mysqldb import MySQL
# configuring MySQL database
app.config['MYSQL_HOST'] = 'cat95.mysql.pythonanywhere-services.com'
app.config['MYSQL_USER'] = 'cat95'
app.config['MYSQL_PASSWORD'] = 'Y8YyuP9TSFj@@Yu'
app.config['MYSQL_DB'] = 'cat95$covid_reporter'
mysql = MySQL(app)

# body of the program where AOIs are defined
parser = reqparse.RequestParser()

class Welcome(Resource):
    def get(self):
        return 'welcome to COVID-19 report', 200

# Class where APIs are defined to get unique user ID
class GetUniqueUserID(Resource):
    def post(self):
        # initiating sql connection object
        cur = mysql.connection.cursor()

        # parsing data from request
        try:
            json_data = request.get_json(force=True)
            auth_key = json_data['auth_key']
            age_lower = json_data['age_lower']
            age_upper = json_data['age_upper']
            lat = json_data['lat']
            lon = json_data['lon']
            gender = json_data['gender']

            if(auth_key and age_lower and age_upper and lat and lon and gender):
                if(auth_key == "sy%6sO128?o*shH@"):
                    _id = get_unique_id(lat = lat, lon = lon, age_lower = age_lower , age_upper = age_upper)
                    cur.execute('SELECT id FROM user_map WHERE id = "{}";'.format(_id))
                    data = cur.fetchall()
                    # if len(data) is not = 0, then there is a collision, we need to regenerate another id
                    while(len(data) != 0):
                        print("ID collision detected")
                        _id = get_unique_id(lat = lat, lon = lon, age_lower = age_lower , age_upper = age_upper, gender = gender)
                        cur.execute('SELECT id FROM user_map WHERE id = "{}";'.format(_id))
                        data = cur.fetchall()

                    # entering the id to database
                    cur.execute('INSERT INTO user_map VALUES ("{}", "{}", "{}", "{}", "{}", "{}", "{}", "{}");'.format(_id, str(age_lower), str(age_upper), gender, str(lat), str(lon), str(lat), str(lon)))
                    mysql.connection.commit()
                    encrypted_id = encrypt_message(_id)
                    return {"data": {"response": "success", "id": encrypted_id}},200
                else:
                    return {"data": {"response": "error", "id": "NA"}},200
            else:
               return {"data": {"response": "error", "message": "invalid payload"}},200

        except Exception as e:
            print(e)
            return {"data": {"response": "error", "message": "invalid payload"}},200

# Class where APIs are defined to check whether the encrypted user is valid or not
class ValidateUser(Resource):
    def post(self):
        # initiating sql connection object
        cur = mysql.connection.cursor()
        # parsing data from request
        try:
            json_data = request.get_json(force=True)
            auth_key = json_data['auth_key']
            encrypted_id = json_data['encrypted_id']
            # print(encrypted_id)
            # print(type(encrypted_id))

            if(auth_key and encrypted_id):
                if(auth_key == "sy%6sO128?o*shH@"):
                    _id = decrypt_message(encrypted_id)
                    cur.execute('SELECT id FROM user_map WHERE id = "{}";'.format(_id))
                    data = cur.fetchall()
                    if(len(data) == 1):
                        return {"data": {"response": "success", "message": "user exists"}},200
                    else:
                        return {"data": {"response": "error", "message": "user doesn't esist"}},200
            else:
               return {"data": {"response": "error", "message": "invalid payload"}},200

        except Exception as e:
            print(e)
            return {"data": {"response": "error", "message": "invalid payload"}},200


# Class where APIs are defined to report a corona case
# Class where APIs are defined to check whether the encrypted user is valid or not
class ReportCorona(Resource):
    def post(self):
        # initiating sql connection object
        cur = mysql.connection.cursor()
        # parsing data from request
        try:
            json_data = request.get_json(force=True)
            auth_key = json_data['auth_key']
            case_lat = json_data['case_lat']
            case_lon = json_data['case_lon']
            case_age_lower = json_data['case_age_lower']
            case_age_upper = json_data['case_age_upper']
            case_gender = json_data['case_gender']
            date_of_information = json_data['date_of_information']
            date_of_report = json_data['date_of_report']
            note = json_data['note']
            encrypted_id = json_data['reported_by']

            if(auth_key and encrypted_id):
                if(auth_key == "sy%6sO128?o*shH@"):
                    _id = decrypt_message(encrypted_id)
                    cur.execute('SELECT id FROM user_map WHERE id = "{}";'.format(_id))
                    data = cur.fetchall()
                    if(len(data) == 1):
                        # this means user is valid, now we will store the reported corona case
                        # entering the id to database
                        cur.execute('INSERT INTO reported_case_table (case_lat, case_lon, case_age_lower, case_age_upper, case_gender, date_of_information, date_of_report, note, points, reported_by, system_time, is_deleted) VALUES("{}","{}","{}","{}","{}","{}","{}","{}",1,"{}", "{}", "{}");'.format(str(case_lat), str(case_lon), str(case_age_lower), str(case_age_upper), case_gender, date_of_information, date_of_report, note, _id, datetime.now().strftime('%Y-%m-%d %H:%M:%S'), "0"))
                        mysql.connection.commit()
                        return {"data": {"response": "success", "message": "case report successful"}},200

                    else:
                        return {"data": {"response": "error", "message": "user doesn't esist"}},200
            else:
               return {"data": {"response": "error", "message": "invalid payload"}},200

        except Exception as e:
            print(e)
            return {"data": {"response": "error", "message": "invalid payload"}},200


# Class where APIs are defined to get the list of reported cases within a certain distance in meters
class GetReportedCasesList(Resource):
    def post(self):
        # initiating sql connection object
        cur = mysql.connection.cursor()
        # parsing data from request
        try:
            json_data = request.get_json(force=True)
            auth_key = json_data['auth_key']
            encrypted_id = json_data['encrypted_id']
            d = json_data['d']
            my_lat = json_data['my_lat']
            my_lon = json_data['my_lon']

            if(auth_key and encrypted_id):
                if(auth_key == "sy%6sO128?o*shH@"):
                    _id = decrypt_message(encrypted_id)
                    cur.execute('SELECT id FROM user_map WHERE id = "{}";'.format(_id))
                    data = cur.fetchall()
                    if(len(data) == 1):
                        # this means user is valid, now we can search for the reported caes
                        cur.execute('SELECT case_id, case_lat, case_lon, system_time, note, points, reported_by, case_age_lower, case_age_upper, case_gender FROM reported_case_table WHERE is_deleted = 0;')
                        all_data = cur.fetchall()
                        # also we need to check for which cases he/she has already cited
                        cur.execute('SELECT case_id from citation_table WHERE cited_by = "{}";'.format(_id))
                        citation_data = cur.fetchall()
                        case_ids_cited = []
                        for i in citation_data:
                            case_ids_cited.append(i[0])
                        # print(case_ids_cited)

                        data_to_be_sent = [];
                        for each_data in all_data:
                            # print(each_data)
                            calc_dist = haversine(float(each_data[1]), float(each_data[2]), float(my_lat), float(my_lon))
                            if( calc_dist <= float(d)):

                                can_cite = ""
                                if(each_data[6] == _id):
                                    can_cite = "0"
                                elif(each_data[0] not in case_ids_cited):
                                    can_cite = "1"
                                else:
                                    can_cite = "0"

                                data_to_be_sent.append({
                                    "case_id" : each_data[0],
                                    "points": each_data[5],
                                    "d_from_u": str(calc_dist),
                                    "reported_date": str(each_data[3]),
                                    "reported_lat": str(each_data[1]),
                                    "reported_lon": str(each_data[2]),
                                    "note": each_data[4],
                                    "can_cite" : can_cite,
                                    "can_delete": "1" if (each_data[6] == _id) else "0",
                                    "age_group": str(each_data[7])+" - "+str(each_data[8]),
                                    "sex": str(each_data[9])
                                    })

                        return {"data": {"response": "success", "message": sorted(data_to_be_sent, key=lambda k: k["points"], reverse = True)}},200
                    else:
                        return {"data": {"response": "error", "message": "user doesn't esist"}},200
            else:
               return {"data": {"response": "error", "message": "invalid payload"}},200

        except Exception as e:
            print(e)
            return {"data": {"response": "error", "message": "invalid payload"}},200

# Class where APIs are defined to delete reported case
class DeleteReportedCase(Resource):
    def post(self):
        # initiating sql connection object
        cur = mysql.connection.cursor()
        # parsing data from request
        try:
            json_data = request.get_json(force=True)
            auth_key = json_data['auth_key']
            case_id = json_data['case_id']
            encrypted_id = json_data['encrypted_user_id']

            if(auth_key and encrypted_id):
                if(auth_key == "sy%6sO128?o*shH@"):
                    _id = decrypt_message(encrypted_id)
                    cur.execute('SELECT id FROM user_map WHERE id = "{}";'.format(_id))
                    data = cur.fetchall()
                    if(len(data) == 1):
                        # this means user is valid, now we will check whether he/she is valid to delete
                        cur.execute('SELECT reported_by from reported_case_table WHERE case_id = "{}";'.format(case_id))
                        data = cur.fetchall()
                        # print(data)
                        if(data[0][0] == _id):
                            # that means we can delete the case
                            cur.execute('UPDATE reported_case_table SET is_deleted = 1 WHERE case_id = "{}";'.format(case_id))
                            mysql.connection.commit()
                            return {"data": {"response": "success", "message": "case delete successful"}},200
                        else:
                            return {"data": {"response": "error", "message": "you are not authorized"}},200
                    else:
                        return {"data": {"response": "error", "message": "user doesn't esist"}},200
            else:
               return {"data": {"response": "error", "message": "invalid payload"}},200

        except Exception as e:
            print(e)
            return {"data": {"response": "error", "message": "invalid payload"}},200


# Class where APIs are defined to cite one reported corona case
class CiteReportedCase(Resource):
    def post(self):
        # initiating sql connection object
        cur = mysql.connection.cursor()
        # parsing data from request
        try:
            json_data = request.get_json(force=True)
            auth_key = json_data['auth_key']
            case_id = json_data['case_id']
            encrypted_id = json_data['encrypted_user_id']

            if(auth_key and encrypted_id):
                if(auth_key == "sy%6sO128?o*shH@"):
                    _id = decrypt_message(encrypted_id)
                    cur.execute('SELECT id FROM user_map WHERE id = "{}";'.format(_id))
                    data = cur.fetchall()
                    if(len(data) == 1):
                        # this means user is valid, now we will check whether he/she is valid for citation which require
                        # he/she is not the creator of the report
                        # he/she has not already cited

                        # first lets get the creator of the report
                        cur.execute('SELECT reported_by from reported_case_table WHERE case_id = "{}";'.format(case_id))
                        data = cur.fetchall()
                        if(data[0][0] != _id): # that means he/she has not created
                            # now we need to varify whether he/she has not already cited
                            cur.execute('SELECT cited_by from citation_table WHERE case_id = "{}";'.format(case_id))
                            data = cur.fetchall()
                            if(len(data) == 0):
                                # we are good to go
                                cur.execute('INSERT INTO citation_table VALUES ("{}","{}");'.format(case_id, _id))
                                mysql.connection.commit()
                                cur.execute('UPDATE reported_case_table SET points = points + 1 WHERE case_id = "{}";'.format(case_id, _id))
                                mysql.connection.commit()
                                return {"data": {"response": "success", "message": "successfully cited"}},200
                            else:
                                for each in data:
                                    if(each[0] == _id):
                                        return {"data": {"response": "error", "message": "you already cited"}},200
                                # we are good to go
                                cur.execute('INSERT INTO citation_table VALUES ("{}","{}");'.format(case_id, _id))
                                mysql.connection.commit()
                                cur.execute('UPDATE reported_case_table SET points = points + 1 WHERE case_id = "{}";'.format(case_id, _id))
                                mysql.connection.commit()
                                return {"data": {"response": "success", "message": "successfully cited"}},200
                        else:
                           return {"data": {"response": "error", "message": "you are not allowed"}},200

                    else:
                        return {"data": {"response": "error", "message": "user doesn't esist"}},200
            else:
               return {"data": {"response": "error", "message": "invalid payload"}},200

        except Exception as e:
            print(e)
            return {"data": {"response": "error", "message": "invalid payload"}},200




api.add_resource(Welcome, '/')
api.add_resource(GetUniqueUserID, '/getUserID')
api.add_resource(ValidateUser, '/validateUserID')
api.add_resource(ReportCorona, '/reportCase')
api.add_resource(GetReportedCasesList, '/getReportedCases')
api.add_resource(DeleteReportedCase, '/deleteReportedCase')
api.add_resource(CiteReportedCase, '/citeReportedCase')


if __name__ == '__main__':
    app.run(threaded=True)