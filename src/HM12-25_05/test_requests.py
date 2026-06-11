import requests
import json
import time

BASE_URL = 'http://127.0.0.1:5000/students'

def log_result(file, step_name, response):
    output = f"\n--- {step_name} ---\n"
    output += f"Status Code: {response.status_code}\n"
    try:
        output += f"Response: {json.dumps(response.json(), indent=2)}\n"
    except ValueError:
        output += f"Response: {response.text}\n"
    
    print(output)
    file.write(output + "\n")

def run_tests():
    # Wait for the server to start
    time.sleep(2)
    
    with open('results.txt', 'w', encoding='utf-8') as f:
        # 1. Retrieve all existing students (GET).
        res = requests.get(BASE_URL)
        log_result(f, "1. Retrieve all existing students (GET)", res)
        
        # 2. Create three students (POST).
        students_to_create = [
            {"first_name": "Alice", "last_name": "Smith", "age": 20},
            {"first_name": "Bob", "last_name": "Jones", "age": 22},
            {"first_name": "Charlie", "last_name": "Brown", "age": 21}
        ]
        created_ids = []
        for i, student in enumerate(students_to_create, 1):
            res = requests.post(BASE_URL, json=student)
            log_result(f, f"2.{i}. Create student {i} (POST)", res)
            if res.status_code == 201:
                created_ids.append(res.json().get('id'))
        
        # 3. Retrieve information about all existing students (GET).
        res = requests.get(BASE_URL)
        log_result(f, "3. Retrieve information about all existing students (GET)", res)
        
        # 4. Update the age of the second student (PATCH).
        if len(created_ids) >= 2:
            second_id = created_ids[1]
            res = requests.patch(f"{BASE_URL}/{second_id}", json={"age": 25})
            log_result(f, "4. Update the age of the second student (PATCH)", res)
            
            # 5. Retrieve information about the second student (GET).
            res = requests.get(f"{BASE_URL}/{second_id}")
            log_result(f, "5. Retrieve information about the second student (GET)", res)
        
        # 6. Update the first name, last name and the age of the third student (PUT).
        if len(created_ids) >= 3:
            third_id = created_ids[2]
            res = requests.put(f"{BASE_URL}/{third_id}", json={
                "first_name": "Charles",
                "last_name": "Darwin",
                "age": 30
            })
            log_result(f, "6. Update the first name, last name and the age of the third student (PUT)", res)
            
            # 7. Retrieve information about the third student (GET).
            res = requests.get(f"{BASE_URL}/{third_id}")
            log_result(f, "7. Retrieve information about the third student (GET)", res)
        
        # 8. Retrieve all existing students (GET).
        res = requests.get(BASE_URL)
        log_result(f, "8. Retrieve all existing students (GET)", res)
        
        # 9. Delete the first user (DELETE).
        if len(created_ids) >= 1:
            first_id = created_ids[0]
            res = requests.delete(f"{BASE_URL}/{first_id}")
            log_result(f, "9. Delete the first user (DELETE)", res)
            
        # 10. Retrieve all existing students (GET).
        res = requests.get(BASE_URL)
        log_result(f, "10. Retrieve all existing students (GET)", res)

if __name__ == '__main__':
    run_tests()
