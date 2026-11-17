use super::template_filters;
use cognix_completion_metadata::CommandSignatureGenerators;

pub fn generator() -> CommandSignatureGenerators {
    CommandSignatureGenerators::new("pod").add_filter("filter-podspec", template_filters::podspec())
}
