import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../constants/style.dart';
import '../../../components/page_title.dart';
import '../../../utils/responsive.dart';

class PredictDemandPage extends StatefulWidget {
  @override
  _PredictDemandPageState createState() => _PredictDemandPageState();
}

class _PredictDemandPageState extends State<PredictDemandPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  int? _predictedDemand;
  DateTime? _selectedDate;
  final _temperatureController = TextEditingController();
  final _dateController = TextEditingController();

  Future<void> _submitPrediction() async {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      setState(() => _isLoading = true);
      
      try {
        final response = await http.post(
          Uri.parse('http://localhost:8000/predict_demand/'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'date': _selectedDate!.toIso8601String(),
            'temperature': double.parse(_temperatureController.text),
          }),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Prediction completed successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          throw Exception('Failed to get prediction: ${response.body}');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all fields correctly'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _formatDateInput(String value) {
    String numbers = value.replaceAll(RegExp(r'[^0-9]'), '');
    String formattedDate = '';

    for (int i = 0; i < numbers.length && i < 8; i++) {
      if (i == 2 || i == 4) {
        formattedDate += '/';
      }
      formattedDate += numbers[i];
    }

    _dateController.value = TextEditingValue(
      text: formattedDate,
      selection: TextSelection.collapsed(offset: formattedDate.length),
    );
  }

  Widget _buildResultPanel() {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Predicted Demand",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: defaultPadding),
          if (_isLoading)
            Center(child: CircularProgressIndicator())
          else if (_predictedDemand != null)
            Container(
              padding: EdgeInsets.all(defaultPadding),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: primaryColor.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.insights, color: primaryColor),
                  SizedBox(width: defaultPadding),
                  Text(
                    "Expected Deliveries: $_predictedDemand",
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: EdgeInsets.all(defaultPadding),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Center(
                child: Text(
                  "Submit the form to see prediction",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMainForm() {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: cardShadow,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Single date input field
            TextFormField(
              controller: _dateController,
              decoration: InputDecoration(
                labelText: 'Date (DD/MM/YYYY)',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[900],
                prefixIcon: Icon(Icons.calendar_today),
                helperText: 'Format: DD/MM/YYYY (e.g., 25/12/2023)',
                errorMaxLines: 2,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                LengthLimitingTextInputFormatter(10),
                FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
              ],
              onChanged: _formatDateInput,
              validator: (val) {
                if (val == null || val.isEmpty) return 'Required';
                if (val.length < 10) return 'Please complete the date (DD/MM/YYYY)';
                if (!RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(val)) {
                  return 'Invalid format. Use: DD/MM/YYYY';
                }

                final parts = val.split('/');
                final day = int.tryParse(parts[0]);
                final month = int.tryParse(parts[1]);
                final year = int.tryParse(parts[2]);

                if (day == null || month == null || year == null) {
                  return 'Invalid date numbers';
                }
                if (day < 1 || day > 31) return 'Day must be between 1-31';
                if (month < 1 || month > 12) return 'Month must be between 1-12';
                if (year < 2020 || year > 2025) return 'Year must be between 2020-2025';

                try {
                  _selectedDate = DateTime(year, month, day);
                  // Check if it's a valid date (e.g., not 31/04/2023)
                  if (_selectedDate!.day != day || 
                      _selectedDate!.month != month || 
                      _selectedDate!.year != year) {
                    return 'Invalid date for selected month';
                  }
                } catch (e) {
                  return 'Invalid date';
                }
                return null;
              },
            ),
            SizedBox(height: defaultPadding),
            // Temperature input remains unchanged
            TextFormField(
              controller: _temperatureController,
              decoration: InputDecoration(
                labelText: 'Temperature (°C)',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[900],
                prefixIcon: Icon(Icons.thermostat),
                helperText: 'Enter temperature between -50°C and 60°C',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*$')),
              ],
              validator: (val) {
                if (val == null || val.isEmpty) return 'Required';
                final temp = double.tryParse(val);
                if (temp == null) return 'Invalid temperature';
                if (temp < -50 || temp > 60) {
                  return 'Temperature must be between -50°C and 60°C';
                }
                return null;
              },
            ),
            SizedBox(height: defaultPadding * 2),
            Center(child: _buildSubmitButton()),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      child: _isLoading
          ? CircularProgressIndicator()
          : ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: defaultPadding * 3,
                  vertical: defaultPadding,
                ),
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _submitPrediction,
              icon: Icon(Icons.analytics),
              label: Text(
                "Predict Demand",
                style: TextStyle(fontSize: 16),
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            PageTitle(
              title: "Demand Prediction",
              subtitle: "Predict delivery demands based on temperature",
              icon: Icons.trending_up,
              actions: [
                IconButton(
                  icon: Icon(Icons.help_outline),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("Help"),
                        content: Text(
                            "Enter the temperature to predict the number of expected deliveries."),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text("OK"),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: defaultPadding),
            Container(
              width: double.infinity,
              child: Responsive.isMobile(context)
                  ? Column(
                      children: [
                        _buildMainForm(),
                        SizedBox(height: defaultPadding),
                        _buildResultPanel(),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: _buildMainForm(),
                        ),
                        SizedBox(width: defaultPadding),
                        Expanded(
                          flex: 2,
                          child: _buildResultPanel(),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _dateController.dispose();
    _temperatureController.dispose();
    super.dispose();
  }
}
