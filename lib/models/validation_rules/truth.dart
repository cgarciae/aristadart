part of arista;

class Truth extends ValidationRule {
  
    final bool truth;
    
    const Truth([this.truth]) : super("truth");

    @override
    bool validate (value)
        => value is bool && value == truth;
}