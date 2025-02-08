import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../constants/style.dart';
import '../../../components/header.dart';
import '../../../utils/responsive.dart';
import '../../../components/page_header.dart';
import '../../../components/page_title.dart';

class PredictRiskPage extends StatefulWidget {
  @override
  _PredictRiskPageState createState() => _PredictRiskPageState();
}

class _PredictRiskPageState extends State<PredictRiskPage> {
  final _formKey = GlobalKey<FormState>();
  bool? _predictionResult;
  bool _isLoading = false;

  // Input field controllers
  final _distanceController = TextEditingController();
  final _driverExperienceController = TextEditingController();
  final _loadingWeightController = TextEditingController();
  final _vehicleYearController = TextEditingController();

  // Dropdown values
  String? _weatherCondition;
  String? _trafficLevel;
  String? _vehicleType;
  String? _goodsType;
  String? _driverExperience;

  // Updated options for dropdowns
  final _weatherConditions = [
    'Stormy',
    'Rainy',
    'Snowy',
    'Clear',
    'Foggy',
    'Cloudy'
  ];
  
  final _trafficLevels = [
    'Medium',
    'Low',
    'Severe',
    'High'
  ];
  
  final _vehicleTypes = [
    'Refrigerated Truck',
    'Large Truck',
    'Medium Truck',
    'Small Van'
  ];
  
  final _driverExperienceLevels = [
    'Novice',
    'Intermediate',
    'Expert'
  ];
  
  final _goodsTypes = [
    'Fragile',
    'Perishable',
    'Hazardous Materials',
    'General Cargo'
  ];

  // Helper method to convert experience level to years
  int _getExperienceYears(String level) {
    switch (level) {
      case 'Novice':
        return 1;
      case 'Intermediate':
        return 3;
      case 'Expert':
        return 5;
      default:
        return 0;
    }
  }

  // Update the submit method to handle experience levels
  Future<void> _submitPrediction() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        final response = await http.post(
          Uri.parse('http://localhost:8000/predict/'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'Weather_Condition': _weatherCondition,
            'Distance_km': double.parse(_distanceController.text),
            'Traffic_Level': _trafficLevel,
            'Vehicle_Type': _vehicleType,
            'Driver_Experience_years': _getExperienceYears(_driverExperience ?? 'Novice'),
            'Goods_Type': _goodsType,
            'Loading_Weight_kg': double.parse(_loadingWeightController.text),
            'Year_of_Vehicle': int.parse(_vehicleYearController.text)
          }),
        );

        if (response.statusCode == 200) {
          final result = jsonDecode(response.body);
          setState(() {
            _predictionResult = result['Delivery_Delay'] == 1;
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            PageTitle(
              title: "Risk Prediction",
              subtitle: "Analyze and predict delivery risks",
              icon: Icons.analytics,
              actions: [
                IconButton(
                  icon: Icon(Icons.help_outline),
                  onPressed: () {
                    // Show help dialog
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("Help"),
                        content: Text("Fill in all the fields to predict delivery risks."),
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

  Widget _buildInfoHeader() {
    return PageHeader(
      title: "Delivery Risk Assessment",
      subtitle: "Fill in all fields to get an accurate prediction of delivery risks",
      icon: Icons.analytics,
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
            "Prediction Result",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: defaultPadding),
          if (_isLoading)
            Center(child: CircularProgressIndicator())
          else if (_predictionResult != null)
            _buildPredictionResult()
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
          // Add additional information or tips here
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: primaryColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.analytics, color: primaryColor, size: 32),
          SizedBox(width: defaultPadding),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Delivery Risk Assessment",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Fill in the details below to predict delivery risks",
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection(String title, List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
          SizedBox(height: defaultPadding),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      child: _isLoading
          ? Center(child: CircularProgressIndicator())
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
                "Predict Delivery Risk",
                style: TextStyle(fontSize: 16),
              ),
            ),
    );
  }

  Widget _buildDropdownField(
    String label,
    List<String> items,
    String? value,
    void Function(String?) onChanged, {
    IconData? icon,
  }) {
    return SizedBox(
      width: 300,
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey[900],
          prefixIcon: icon != null ? Icon(icon) : null,
        ),
        value: value,
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (val) => val == null ? 'Required' : null,
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    TextInputType keyboardType, {
    IconData? icon,
  }) {
    return SizedBox(
      width: 300,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey[900],
          prefixIcon: icon != null ? Icon(icon) : null,
          // Add helper text to show valid range
          helperText: keyboardType == TextInputType.number 
              ? 'Enter numbers only'
              : null,
        ),
        keyboardType: keyboardType,
        // Add input formatting for numbers
        inputFormatters: keyboardType == TextInputType.number
            ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))]
            : null,
        // Enhanced validator
        validator: (val) {
          if (val == null || val.isEmpty) {
            return 'Required';
          }
          if (keyboardType == TextInputType.number) {
            if (!RegExp(r'^\d*\.?\d*$').hasMatch(val)) {
              return 'Numbers only';
            }
            // Add range validation for specific fields
            double? numVal = double.tryParse(val);
            if (numVal == null) {
              return 'Invalid number';
            }
            if (label == 'Distance (km)' && (numVal <= 0 || numVal > 10000)) {
              return 'Enter valid distance (0-10000 km)';
            }
            if (label == 'Loading Weight (kg)' && (numVal <= 0 || numVal > 50000)) {
              return 'Enter valid weight (0-50000 kg)';
            }
            if (label == 'Vehicle Year') {
              int? year = int.tryParse(val);
              if (year == null || year < 1990 || year > DateTime.now().year) {
                return 'Enter valid year (1990-${DateTime.now().year})';
              }
            }
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPredictionResult() {
    return Container(
      margin: EdgeInsets.only(top: defaultPadding),
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: _predictionResult! ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _predictionResult! ? Colors.red.withOpacity(0.5) : Colors.green.withOpacity(0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _predictionResult! ? Icons.warning : Icons.check_circle,
            color: _predictionResult! ? Colors.red : Colors.green,
          ),
          SizedBox(width: defaultPadding),
          Text(
            _predictionResult! ? "High Risk of Delay" : "Low Risk of Delay",
            style: TextStyle(
              color: _predictionResult! ? Colors.red : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftColumn() {
    return Column(
      children: [
        _buildFormSection(
          "Environmental Factors",
          [
            _buildDropdownField(
              'Weather Condition',
              _weatherConditions,
              _weatherCondition,
              (val) => setState(() => _weatherCondition = val),
              icon: Icons.cloud,
            ),
            SizedBox(height: defaultPadding),
            _buildDropdownField(
              'Traffic Level',
              _trafficLevels,
              _trafficLevel,
              (val) => setState(() => _trafficLevel = val),
              icon: Icons.traffic,
            ),
          ],
        ),
        SizedBox(height: defaultPadding),
        _buildFormSection(
          "Vehicle Information",
          [
            _buildDropdownField(
              'Vehicle Type',
              _vehicleTypes,
              _vehicleType,
              (val) => setState(() => _vehicleType = val),
              icon: Icons.local_shipping,
            ),
            SizedBox(height: defaultPadding),
            _buildInputField(
              'Vehicle Year',
              _vehicleYearController,
              TextInputType.number,
              icon: Icons.calendar_today,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRightColumn() {
    return Column(
      children: [
        _buildFormSection(
          "Delivery Details",
          [
            _buildInputField(
              'Distance (km)',
              _distanceController,
              TextInputType.number,
              icon: Icons.route,
            ),
            SizedBox(height: defaultPadding),
            _buildInputField(
              'Loading Weight (kg)',
              _loadingWeightController,
              TextInputType.number,
              icon: Icons.scale,
            ),
          ],
        ),
        SizedBox(height: defaultPadding),
        _buildFormSection(
          "Personnel & Cargo",
          [
            _buildDropdownField(
              'Driver Experience',
              _driverExperienceLevels,
              _driverExperience,
              (val) => setState(() => _driverExperience = val),
              icon: Icons.person,
            ),
            SizedBox(height: defaultPadding),
            _buildDropdownField(
              'Goods Type',
              _goodsTypes,
              _goodsType,
              (val) => setState(() => _goodsType = val),
              icon: Icons.inventory,
            ),
          ],
        ),
      ],
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoHeader(),
          Divider(height: defaultPadding * 2),
          Form(
            key: _formKey,
            child: Column(
              children: [
                if (Responsive.isMobile(context))
                  Column(
                    children: [
                      _buildLeftColumn(),
                      SizedBox(height: defaultPadding),
                      _buildRightColumn(),
                    ],
                  )
                else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildLeftColumn()),
                      SizedBox(width: defaultPadding * 2),
                      Expanded(child: _buildRightColumn()),
                    ],
                  ),
                SizedBox(height: defaultPadding * 2),
                _buildSubmitButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _distanceController.dispose();
    _driverExperienceController.dispose();
    _loadingWeightController.dispose();
    _vehicleYearController.dispose();
    super.dispose();
  }
}
