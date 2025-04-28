# smart_finance_lstm_production.py

import numpy as np
import pandas as pd
import tensorflow as tf
from sklearn.model_selection import train_test_split
import matplotlib.pyplot as plt
import os
import logging
from datetime import datetime

# ========== Global Settings ==========
SCALE_FACTOR = 100000  # 1 lakh scaling
SAMPLES = 4000
MONTHS = 6
EPOCHS = 80
BATCH_SIZE = 32
USE_ADAMW = False  # Toggle AdamW optimizer
OUTPUT_DIR = "outputs"
MODELS_DIR = os.path.join(OUTPUT_DIR, "models")
PREDICTIONS_DIR = os.path.join(OUTPUT_DIR, "predictions")

# Setup logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# Ensure output folders exist
os.makedirs(MODELS_DIR, exist_ok=True)
os.makedirs(PREDICTIONS_DIR, exist_ok=True)

# ========== Step 1: Generate Synthetic Monthly Sequence Data ==========
def generate_sequence_data(samples=SAMPLES, months=MONTHS):
    np.random.seed(42)
    tf.random.set_seed(42)
    X, y_months, y_goal = [], [], []

    for _ in range(samples):
        income = np.random.randint(20000, 10000000)
        goal_amount = np.random.randint(100000, 50000000)
        fixed = np.random.randint(5000, 5000000)
        taxi = np.random.randint(100, 100000)
        grocery = np.random.randint(500, 200000)
        party = np.random.randint(0, 300000)
        restaurant = np.random.randint(0, 200000)
        shopping = np.random.randint(0, 500000)
        target_months = np.random.randint(6, 60)

        monthly_sequence = []
        for _ in range(months):
            monthly_income = income + np.random.randint(-50000, 50000)
            monthly_fixed = fixed + np.random.randint(-20000, 20000)
            monthly_taxi = taxi + np.random.randint(-5000, 5000)
            monthly_grocery = grocery + np.random.randint(-10000, 10000)
            monthly_party = party + np.random.randint(-15000, 15000)
            monthly_restaurant = restaurant + np.random.randint(-8000, 8000)
            monthly_shopping = shopping + np.random.randint(-25000, 25000)

            saving = monthly_income - (monthly_fixed + monthly_taxi + monthly_grocery +
                                       monthly_party + monthly_restaurant + monthly_shopping)

            monthly_sequence.append([
                monthly_income / SCALE_FACTOR,
                monthly_fixed / SCALE_FACTOR,
                monthly_taxi / SCALE_FACTOR,
                monthly_grocery / SCALE_FACTOR,
                monthly_party / SCALE_FACTOR,
                monthly_restaurant / SCALE_FACTOR,
                monthly_shopping / SCALE_FACTOR,
                goal_amount / SCALE_FACTOR,
                target_months
            ])

        months_needed = goal_amount / max(saving, 1000)
        goal_possible = 1 if saving > 0 else 0

        X.append(monthly_sequence)
        y_months.append(min(months_needed, 60))
        y_goal.append(goal_possible)

    return np.array(X), np.array(y_months), np.array(y_goal)

# ========== Step 2: Build LSTM Model ==========
def build_lstm_model():
    inputs = tf.keras.Input(shape=(MONTHS, 9))
    x = tf.keras.layers.LSTM(64)(inputs)
    x = tf.keras.layers.Dense(128, activation='relu')(x)
    x = tf.keras.layers.Dropout(0.3)(x)
    x = tf.keras.layers.Dense(64, activation='relu')(x)

    months_pred = tf.keras.layers.Dense(1, activation='linear', name='months_output')(x)
    goal_pred = tf.keras.layers.Dense(1, activation='sigmoid', name='goal_output')(x)

    optimizer = (tf.keras.optimizers.AdamW(learning_rate=0.001) if USE_ADAMW
                 else tf.keras.optimizers.Adam(learning_rate=0.001))

    model = tf.keras.Model(inputs=inputs, outputs=[months_pred, goal_pred])
    model.compile(
        optimizer=optimizer,
        loss={'months_output': 'mae', 'goal_output': 'binary_crossentropy'},
        loss_weights={'months_output': 1.0, 'goal_output': 2.0},
        metrics={'months_output': 'mae', 'goal_output': 'accuracy'}
    )
    return model

# ========== Step 3: Train Model ==========
def train_model(X, y_months, y_goal):
    assert X.shape[1:] == (MONTHS, 9), "Input shape mismatch!"

    X_train, X_test, y_months_train, y_months_test, y_goal_train, y_goal_test = train_test_split(
        X, y_months, y_goal, test_size=0.2, random_state=42)

    model = build_lstm_model()

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    model_path = os.path.join(MODELS_DIR, f'best_model_{timestamp}.keras')

    callbacks = [
        tf.keras.callbacks.ModelCheckpoint(model_path,
                                            monitor='val_goal_output_accuracy',
                                            save_best_only=True,
                                            mode='max',
                                            verbose=1),
        tf.keras.callbacks.EarlyStopping(monitor='val_goal_output_accuracy',
                                          patience=8,
                                          mode='max',
                                          restore_best_weights=True),
        tf.keras.callbacks.ReduceLROnPlateau(monitor='val_goal_output_accuracy',
                                             factor=0.5,
                                             patience=4,
                                             min_lr=1e-5,
                                             mode='max')
    ]

    history = model.fit(
        X_train,
        {'months_output': y_months_train, 'goal_output': y_goal_train},
        validation_split=0.2,
        epochs=EPOCHS,
        batch_size=BATCH_SIZE,
        callbacks=callbacks
    )

    plt.figure(figsize=(10, 5))
    plt.plot(history.history['loss'], label='Train Loss')
    plt.plot(history.history['val_loss'], label='Validation Loss')
    plt.title('Model Loss During Training')
    plt.ylabel('Loss')
    plt.xlabel('Epoch')
    plt.legend()
    plt.grid(True)
    plt.savefig(os.path.join(OUTPUT_DIR, f'training_loss_plot_{timestamp}.png'))
    plt.close()

    return X_test, y_months_test, y_goal_test, model_path

# ========== Step 4: Test Model ==========
def test_model(X_test, y_months_test, y_goal_test, model_path):
    model = tf.keras.models.load_model(model_path)
    preds = model.predict(X_test)
    pred_months = preds[0].flatten()
    pred_goal = (preds[1].flatten() > 0.5).astype(int)

    months_mae = np.mean(np.abs(pred_months - y_months_test))
    goal_acc = np.mean(pred_goal == y_goal_test)

    logging.info(f"\nMAE for months prediction: {months_mae:.2f}")
    logging.info(f"Accuracy for goal prediction: {goal_acc * 100:.2f}%")

    output_file = os.path.join(PREDICTIONS_DIR, f'model_predictions_{datetime.now().strftime("%Y%m%d_%H%M%S")}.xlsx')
    try:
        df = pd.DataFrame({
            'Actual_Months': y_months_test,
            'Predicted_Months': pred_months,
            'Actual_Goal': y_goal_test,
            'Predicted_Goal': pred_goal
        })
        df.to_excel(output_file, index=False)
        logging.info(f"Predictions saved successfully to '{output_file}'.")
    except PermissionError:
        logging.error(f"Permission Denied: Close '{output_file}' if it is open and re-run.")

def predict_user_input(model):
    print("\n--- User Input Prediction ---")

    income = float(input("Enter monthly income (₹): "))
    fixed = float(input("Enter fixed monthly expenses (₹): "))
    taxi = float(input("Enter monthly taxi expense (₹): "))
    grocery = float(input("Enter monthly grocery expense (₹): "))
    party = float(input("Enter monthly party expense (₹): "))
    restaurant = float(input("Enter monthly restaurant expense (₹): "))
    shopping = float(input("Enter monthly shopping expense (₹): "))
    goal_amount = float(input("Enter goal amount to save (₹): "))
    target_months = int(input("Enter target months to achieve goal: "))

    sequence = []
    for _ in range(6):  # simulate 6 months with slight random variations
        monthly_income = income + np.random.randint(-5000, 5000)
        monthly_fixed = fixed + np.random.randint(-2000, 2000)
        monthly_taxi = taxi + np.random.randint(-500, 500)
        monthly_grocery = grocery + np.random.randint(-1000, 1000)
        monthly_party = party + np.random.randint(-3000, 3000)
        monthly_restaurant = restaurant + np.random.randint(-2000, 2000)
        monthly_shopping = shopping + np.random.randint(-5000, 5000)

        sequence.append([
            monthly_income / SCALE_FACTOR,
            monthly_fixed / SCALE_FACTOR,
            monthly_taxi / SCALE_FACTOR,
            monthly_grocery / SCALE_FACTOR,
            monthly_party / SCALE_FACTOR,
            monthly_restaurant / SCALE_FACTOR,
            monthly_shopping / SCALE_FACTOR,
            goal_amount / SCALE_FACTOR,
            target_months
        ])

    sequence = np.array(sequence).reshape(1, 6, 9)

    pred_months, pred_goal = model.predict(sequence)
    pred_months = pred_months.flatten()[0]
    pred_goal = (pred_goal.flatten()[0] > 0.5)

    print("\n📈 Predicted Months Needed:", round(pred_months, 2))
    print("🎯 Goal Possible:", "YES" if pred_goal else "NO")


# ========== Main Pipeline ==========
if __name__ == "__main__":
    logging.info("Generating Data...")
    X, y_months, y_goal = generate_sequence_data(samples=SAMPLES, months=MONTHS)

    logging.info("Training Model...")
    X_test, y_months_test, y_goal_test, model_path = train_model(X, y_months, y_goal)

    logging.info("Testing Model...")
    test_model(X_test, y_months_test, y_goal_test, model_path)