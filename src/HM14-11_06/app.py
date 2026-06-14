import os
import csv
from flask import Flask, request, jsonify

app = Flask(__name__)
CSV_FILE = 'students.csv'

def read_students():
    if not os.path.exists(CSV_FILE):
        return []
    with open(CSV_FILE, mode='r', newline='', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        return [row for row in reader]

def write_students(students):
    with open(CSV_FILE, mode='w', newline='', encoding='utf-8') as f:
        fieldnames = ['id', 'first_name', 'last_name', 'age']
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        for student in students:
            writer.writerow(student)

@app.route('/students', methods=['GET'])
def get_students():
    students = read_students()
    
    last_name = request.args.get('last_name')
    if last_name:
        filtered_students = [s for s in students if s['last_name'] == last_name]
        if not filtered_students:
            return jsonify({'error': 'Student with provided last name not found'}), 404
        return jsonify(filtered_students), 200

    return jsonify(students), 200

@app.route('/students/<int:student_id>', methods=['GET'])
def get_student_by_id(student_id):
    students = read_students()
    for s in students:
        if str(s['id']) == str(student_id):
            return jsonify(s), 200
    return jsonify({'error': 'Student not found'}), 404

@app.route('/students/lastname/<string:last_name>', methods=['GET'])
def get_student_by_last_name(last_name):
    students = read_students()
    filtered_students = [s for s in students if s['last_name'] == last_name]
    if not filtered_students:
        return jsonify({'error': 'Student with provided last name not found'}), 404
    return jsonify(filtered_students), 200

@app.route('/students', methods=['POST'])
def create_student():
    data = request.get_json()
    if not data:
        return jsonify({'error': 'No fields passed'}), 400
    
    required_fields = {'first_name', 'last_name', 'age'}
    provided_fields = set(data.keys())
    
    if provided_fields != required_fields:
        return jsonify({'error': 'Invalid fields provided. Exactly first_name, last_name, and age are required.'}), 400
        
    students = read_students()
    new_id = 1
    if students:
        new_id = max(int(s['id']) for s in students) + 1
        
    new_student = {
        'id': str(new_id),
        'first_name': data['first_name'],
        'last_name': data['last_name'],
        'age': str(data['age'])
    }
    
    students.append(new_student)
    write_students(students)
    
    return jsonify(new_student), 201

@app.route('/students/<int:student_id>', methods=['PUT'])
def update_student(student_id):
    data = request.get_json()
    if not data:
        return jsonify({'error': 'No fields passed'}), 400
        
    required_fields = {'first_name', 'last_name', 'age'}
    provided_fields = set(data.keys())
    
    if provided_fields != required_fields:
        return jsonify({'error': 'Invalid fields provided. Exactly first_name, last_name, and age are required.'}), 400
        
    students = read_students()
    for s in students:
        if str(s['id']) == str(student_id):
            s['first_name'] = data['first_name']
            s['last_name'] = data['last_name']
            s['age'] = str(data['age'])
            write_students(students)
            return jsonify(s), 200
            
    return jsonify({'error': 'Student not found'}), 404

@app.route('/students/<int:student_id>', methods=['PATCH'])
def patch_student(student_id):
    data = request.get_json()
    if not data:
        return jsonify({'error': 'No fields passed'}), 400
        
    required_fields = {'age'}
    provided_fields = set(data.keys())
    
    if provided_fields != required_fields:
        return jsonify({'error': 'Invalid fields provided. Exactly age is required.'}), 400
        
    students = read_students()
    for s in students:
        if str(s['id']) == str(student_id):
            s['age'] = str(data['age'])
            write_students(students)
            return jsonify(s), 200
            
    return jsonify({'error': 'Student not found'}), 404

@app.route('/students/<int:student_id>', methods=['DELETE'])
def delete_student(student_id):
    students = read_students()
    filtered_students = [s for s in students if str(s['id']) != str(student_id)]
    
    if len(students) == len(filtered_students):
        return jsonify({'error': 'Student not found'}), 404
        
    write_students(filtered_students)
    return jsonify({'message': 'Student deleted successfully'}), 200

if __name__ == '__main__':
    app.run(debug=True, port=5000)
