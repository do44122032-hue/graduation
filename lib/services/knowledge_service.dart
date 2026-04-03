import '../models/medical_resource_model.dart';

class KnowledgeService {
  static final List<MedicalResource> _allResources = [
    // Journals
    MedicalResource(
      id: 'j1',
      title: 'New England Journal of Medicine (NEJM)',
      source: 'Massachusetts Medical Society',
      summary: 'The most prestigious and oldest continuously published medical journal in the world.',
      category: 'Journals',
      imageUrl: 'https://images.unsplash.com/photo-1576091160550-217359f42f8c?auto=format&fit=crop&q=80&w=200&h=200',
      isTrending: true,
    ),
    MedicalResource(
      id: 'j2',
      title: 'The Lancet',
      source: 'Elsevier',
      summary: 'One of the world\'s highest-impact weekly general medical journals.',
      category: 'Journals',
      imageUrl: 'https://images.unsplash.com/photo-1532938911079-1b06ac7ceec7?auto=format&fit=crop&q=80&w=200&h=200',
      isTrending: true,
    ),
    MedicalResource(
      id: 'c1',
      title: 'Long-term outcomes of heart valve replacement in elderly patients',
      source: 'Dr. Sarah Wilson, Cardiology',
      summary: 'A 10-year retrospective study analyzing survival rates and quality of life post-surgery.',
      category: 'Doctor Community',
      imageUrl: 'https://images.unsplash.com/photo-1516549655169-df83a0774514?auto=format&fit=crop&q=80&w=200&h=200',
      url: 'https://www.nejm.org/doi/pdf/10.1056/NEJMoa1814052', // Example PDF URL
    ),
    MedicalResource(
      id: 'c2',
      title: 'Advancements in Non-Invasive Glucose Monitoring',
      source: 'Dr. Mike Ross, Internal Medicine',
      summary: 'Reviewing recent sensor technology developments for continuous monitoring.',
      category: 'Doctor Community',
      imageUrl: 'https://images.unsplash.com/photo-1583947215259-38e31be8751f?auto=format&fit=crop&q=80&w=200&h=200',
      isTrending: true,
      url: 'https://www.nature.com/articles/s41746-023-00782-w.pdf', // Example PDF URL
    ),
    MedicalResource(
      id: 'j3',
      title: 'JAMA',
      source: 'American Medical Association',
      summary: 'A peer-reviewed medical journal published 48 times a year.',
      category: 'Journals',
      imageUrl: 'https://images.unsplash.com/photo-1582213726894-44af4460168b?auto=format&fit=crop&q=80&w=200&h=200',
    ),
    MedicalResource(
      id: 'j4',
      title: 'BMJ',
      source: 'BMJ Group',
      summary: 'A high-impact peer-reviewed medical journal and trade journal.',
      category: 'Journals',
      imageUrl: 'https://images.unsplash.com/photo-1559757175-5700dde675bc?auto=format&fit=crop&q=80&w=200&h=200',
    ),

    // Books
    MedicalResource(
      id: 'b1',
      title: 'Harrison\'s Principles of Internal Medicine',
      source: 'McGraw-Hill Education',
      summary: 'The world\'s most trusted clinical medicine text, essential for every clinician.',
      category: 'Books',
      imageUrl: 'https://images.unsplash.com/photo-1544640808-32ca72ac7f37?auto=format&fit=crop&q=80&w=200&h=200',
      isTrending: true,
    ),
    MedicalResource(
      id: 'b2',
      title: 'Gray\'s Anatomy: Basis of Clinical Practice',
      source: 'Elsevier Health Sciences',
      summary: 'Widely regarded as the most complete and influential anatomy textbook.',
      category: 'Books',
      imageUrl: 'https://images.unsplash.com/photo-1583912267550-d44d7085544a?auto=format&fit=crop&q=80&w=200&h=200',
    ),
    MedicalResource(
      id: 'b3',
      title: 'Robbins & Cotran Pathologic Basis of Disease',
      source: 'Elsevier',
      summary: 'The ultimate guide to the pathology underlying clinical disease.',
      category: 'Books',
      imageUrl: 'https://images.unsplash.com/photo-1579154235602-3c2cbbac73ca?auto=format&fit=crop&q=80&w=200&h=200',
    ),

    // Clinical Guidelines
    MedicalResource(
      id: 'g1',
      title: 'WHO Model List of Essential Medicines',
      source: 'World Health Organization',
      summary: 'Guidelines for essential medicines that satisfy the priority health care needs of the population.',
      category: 'Clinical Guidelines',
      imageUrl: 'https://images.unsplash.com/photo-1581056771107-24ca5f033842?auto=format&fit=crop&q=80&w=200&h=200',
    ),
    MedicalResource(
      id: 'g2',
      title: 'PubMed Database',
      source: 'National Institutes of Health',
      summary: 'A free search engine accessing primarily the MEDLINE database of life sciences.',
      category: 'Clinical Guidelines',
      imageUrl: 'https://images.unsplash.com/photo-1456513080510-7bf3a84b82f8?auto=format&fit=crop&q=80&w=200&h=200',
      isTrending: true,
    ),
    MedicalResource(
      id: 'g3',
      title: 'Mayo Clinic Clinical Protocols',
      source: 'Mayo Clinic',
      summary: 'Evidence-based clinical guidelines and protocols for healthcare providers.',
      category: 'Clinical Guidelines',
      imageUrl: 'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?auto=format&fit=crop&q=80&w=200&h=200',
    ),

    // AI Research
    MedicalResource(
      id: 'a1',
      title: 'Generative AI in Clinical Workflow',
      source: 'Nature Digital Medicine',
      summary: 'A study on how LLMs are transforming doctor-patient documentation.',
      category: 'AI Research',
      imageUrl: 'https://images.unsplash.com/photo-1677442136019-21780ecad995?auto=format&fit=crop&q=80&w=200&h=200',
      isTrending: true,
    ),
    MedicalResource(
      id: 'a2',
      title: 'AlphaFold 3: Protein Structure Prediction',
      source: 'Google DeepMind',
      summary: 'Solving the protein structure prediction problem through deep learning.',
      category: 'AI Research',
      imageUrl: 'https://images.unsplash.com/photo-1507413245164-6160d8298b31?auto=format&fit=crop&q=80&w=200&h=200',
    ),
  ];

  static List<MedicalResource> get allResources => _allResources;

  static void addResource(MedicalResource resource) {
    _allResources.insert(0, resource); // Show latest first
  }

  static List<MedicalResource> searchResources(String query, {String? category}) {
    return _allResources.where((resource) {
      final matchesQuery = resource.title.toLowerCase().contains(query.toLowerCase()) ||
          resource.source.toLowerCase().contains(query.toLowerCase()) ||
          resource.summary.toLowerCase().contains(query.toLowerCase());
      
      final matchesCategory = category == null || category == 'All' || resource.category == category;
      
      return matchesQuery && matchesCategory;
    }).toList();
  }

  static List<MedicalResource> getTrending() {
    return _allResources.where((r) => r.isTrending).toList();
  }

  static List<String> getCategories() {
    return ['All', 'Journals', 'Books', 'Clinical Guidelines', 'Doctor Community', 'AI Research'];
  }
}
