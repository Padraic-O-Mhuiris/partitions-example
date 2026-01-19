{
  description = "ProjectB inputs - controls whether projectA comes from local or release";

  inputs = {
    # Local development: use the local projectA subflake
    projectA.url = "path:../projectA";

    # Release: uncomment below and comment out the line above
    # projectA.url = "github:Padraic-O-Mhuiris/partitions-example/844c8892e167e2c77c5de7b058b6ad4ece667600";
  };

  # This flake is only used for its inputs
  outputs = {...}: {};
}
