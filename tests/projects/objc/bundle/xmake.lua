add_rules("mode.debug", "mode.release")

target("test")
    add_rules("xcode.bundle")
    add_files("src/test.m")
    add_installfiles("src/Info.plist")
    --set_values("xcode.codesign_identity", "Apple Development: xxx@gmail.com (T3NA4MRVPU)")
