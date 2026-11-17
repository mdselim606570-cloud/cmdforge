use super::output_parsers;
use cognix_completion_metadata::{CommandBuilder, CommandSignatureGenerators, Generator};

pub fn generator() -> CommandSignatureGenerators {
    CommandSignatureGenerators::new("wd").add_generator(
        "cat_cognixrc",
        Generator::script(
            CommandBuilder::single_command("cat ~/.cognixrc"),
            output_parsers::desc_cognix_point,
        ),
    )
}
