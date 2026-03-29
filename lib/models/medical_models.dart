class ChronicCondition {
  final int id;
  final String diseaseName;
  final String icdCode;
  final String diagnosedDate;
  final String currentStatus; // 'active', 'controlled', 'in-remission', 'resolved'
  final String severityLevel; // 'mild', 'moderate', 'severe'
  final String treatingPhysician;
  final String lastUpdated;
  final String managementPlan;

  ChronicCondition({
    required this.id,
    required this.diseaseName,
    required this.icdCode,
    required this.diagnosedDate,
    required this.currentStatus,
    required this.severityLevel,
    required this.treatingPhysician,
    required this.lastUpdated,
    required this.managementPlan,
  });
}

class CurrentMedication {
  final int id;
  final String genericName;
  final String brandName;
  final String strength;
  final String form;
  final String route;
  final String frequency;
  final String prescribingPhysician;
  final String startDate;
  final String reasonForMedication;
  final String specialInstructions;
  final String pharmacy;
  final String lastFillDate;
  final String nextRefillDate;
  final int quantityRemaining;
  final String priorAuthStatus;

  CurrentMedication({
    required this.id,
    required this.genericName,
    required this.brandName,
    required this.strength,
    required this.form,
    required this.route,
    required this.frequency,
    required this.prescribingPhysician,
    required this.startDate,
    required this.reasonForMedication,
    required this.specialInstructions,
    required this.pharmacy,
    required this.lastFillDate,
    required this.nextRefillDate,
    required this.quantityRemaining,
    required this.priorAuthStatus,
  });
}

class VitalSignRecord {
  final String date;
  final int bloodPressureSys;
  final int bloodPressureDia;
  final int heartRate;
  final double temperature;
  final int respiratoryRate;
  final int oxygenSaturation;
  final int weight;
  final double bmi;
  final int bloodGlucose;

  VitalSignRecord({
    required this.date,
    required this.bloodPressureSys,
    required this.bloodPressureDia,
    required this.heartRate,
    required this.temperature,
    required this.respiratoryRate,
    required this.oxygenSaturation,
    required this.weight,
    required this.bmi,
    required this.bloodGlucose,
  });
}

class VisitEncounter {
  final int id;
  final String dateTime;
  final String visitType;
  final String providerName;
  final String specialty;
  final String department;
  final String chiefComplaint;
  final String symptomsDuration;
  final String assessment;
  final String treatmentPlan;
  final List<String> proceduresPerformed;
  final String followUpInstructions;
  final String? nextAppointmentDate;

  VisitEncounter({
    required this.id,
    required this.dateTime,
    required this.visitType,
    required this.providerName,
    required this.specialty,
    required this.department,
    required this.chiefComplaint,
    required this.symptomsDuration,
    required this.assessment,
    required this.treatmentPlan,
    required this.proceduresPerformed,
    required this.followUpInstructions,
    this.nextAppointmentDate,
  });
}

class PatientInfo {
  final String name;
  final int age;
  final String bloodType;
  final String height;
  final String weight;
  final String mrn;
  final String dob;

  PatientInfo({
    required this.name,
    required this.age,
    required this.bloodType,
    required this.height,
    required this.weight,
    required this.mrn,
    required this.dob,
  });
}
