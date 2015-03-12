part of aristadart.general;

class Truth extends ValidationRule {
  
    final bool truth;
    
    const Truth([this.truth]) : super("truth");

    @override
    bool validate (bool value)
        => value == truth;
}