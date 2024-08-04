import numpy as np
import pandas as pd
import joblib
from flask import Flask, request, jsonify, render_template
import logging

# Load label encoders and scaler
label_encoders = joblib.load(r'C:\Users\ghaza\Desktop\10Pearls\Telco Churn\label_encoders.pkl')
scaler = joblib.load(r'C:\Users\ghaza\Desktop\10Pearls\Telco Churn\scaler.pkl')
model = joblib.load(r'C:\Users\ghaza\Desktop\10Pearls\Telco Churn\telco_churn_model.pkl')

app = Flask(__name__, template_folder='templates')
logging.basicConfig(level=logging.DEBUG)

@app.route('/')
def home():
    return render_template('index.html')

@app.route('/predict', methods=['POST'])
def predict():
    form_data = request.get_json()
    logging.debug(f"Received form data: {form_data}")
    
    # Prepare input data
    input_data = []
    
    # Transform categorical features
    for feature in ['SeniorCitizen','MultipleLines', 'InternetService', 'OnlineSecurity', 'OnlineBackup', 'TechSupport', 'StreamingMovies', 'Contract', 'PaperlessBilling', 'PaymentMethod']:
        if feature in form_data:
            input_data.append(label_encoders[feature].transform([form_data[feature]])[0])
        else:
            input_data.append(None)  # or a default value if applicable

    # Append numerical features directly
    numerical_features = ['tenure', 'MonthlyCharges', 'TotalCharges']
    for feature in numerical_features:
        input_data.append(float(form_data[feature]))

    # Convert to numpy array and reshape
    input_data = np.array([input_data])
    
    # Apply scaling to numerical features
    # Note: Ensure indices match those used in training
    numerical_indices = [1, 11, 12]  # Adjust if necessary
    input_data[:, numerical_indices] = scaler.transform(input_data[:, numerical_indices])
    
    # Create DataFrame for prediction
    feature_names = ['SeniorCitizen', 'tenure', 'MultipleLines', 'InternetService', 'OnlineSecurity', 'OnlineBackup', 'TechSupport', 'StreamingMovies', 'Contract', 'PaperlessBilling', 'PaymentMethod', 'MonthlyCharges', 'TotalCharges']
    final_data = pd.DataFrame(input_data, columns=feature_names)
    
    # Make prediction
    prediction = model.predict(final_data)
    logging.debug(f"Prediction: {prediction}")
    
    return jsonify({'prediction': int(prediction[0])})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001, debug=True)