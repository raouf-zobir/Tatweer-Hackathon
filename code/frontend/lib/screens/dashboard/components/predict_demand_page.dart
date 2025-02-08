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

  // Controllers
  final _temperatureController = TextEditingController();
  final List<String> _daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  String? _selectedDay;

  Future<void> _submitPrediction() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        final response = await http.post(
          Uri.parse('http://localhost:8000/predict_demand/'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'day_of_week': _selectedDay,
            'temperature': double.parse(_temperatureController.text),
          }),
        );

        if (response.statusCode == 200) {
          final result = jsonDecode(response.body);
          setState(() {
            _predictedDemand = result['predicted_demand'];
            _isLoading = false;
          });
        } else {
          throw Exception('Failed to get prediction');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
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
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Day of Week',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[900],
                prefixIcon: Icon(Icons.calendar_today),
              ),
              value: _selectedDay,
              items: _daysOfWeek.map((String day) {
                return DropdownMenuItem<String>(
                  value: day,
                  child: Text(day),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedDay = value),
              validator: (val) => val == null ? 'Please select a day' : null,
            ),
            SizedBox(height: defaultPadding),
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
                if (val == null || val.isEmpty) {
                  return 'Required';
                }
                final temp = double.tryParse(val);
                if (temp == null) {
                  return 'Invalid temperature';
                }
                if (temp < -50 || temp > 60) {
                  return 'Temperature must be between -50°C and 60°C';
                }
                return null;
              },
            ),
            SizedBox(height: defaultPadding * 2),
            Center(
              child: _buildSubmitButton(),
            ),
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
              subtitle: "Predict delivery demands based on day and temperature",
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
                            "Enter the day of the week and temperature to predict the number of expected deliveries."),
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
    _temperatureController.dispose();
    super.dispose();
  }
}
