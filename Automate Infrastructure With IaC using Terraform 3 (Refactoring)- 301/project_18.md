# Automating Infrastructure with Terraform 3 (Refactoring)

In the previous projects, you created AWS infrastructure code using Terraform and executed it from your local workstation. Now, it's time to dive into more advanced concepts and refine your code.

We’ll start by exploring alternative Terraform [backends](https://developer.hashicorp.com/terraform/language/settings/backends/configuration).

## Introducing S3 Backend

Each Terraform configuration can specify a backend, which determines where and how operations are performed, where state snapshots are stored, and more. The state file, which Terraform uses to store the infrastructure's state in JSON format, is a crucial component. Up until now, we've been utilizing the default `local backend`—this requires no configuration and stores the state file locally. While this approach may suffice for learning, it isn't a reliable long-term solution. Storing the state file locally can pose challenges, particularly in a team setting, as other DevOps engineers won’t have access to the state file on your computer.

To address this, we will configure a backend that allows the state file to be accessed remotely by other team members. Terraform supports various standard backends; since we’re already using AWS, we’ll opt for an [S3 bucket as our backend](https://developer.hashicorp.com/terraform/language/settings/backends/s3).

Additionally, the S3 backend supports [State Locking](https://developer.hashicorp.com/terraform/language/state/locking), which locks the state during operations that could modify it. This feature helps prevent others from acquiring the lock and potentially corrupting the state file. State locking in the S3 backend is optional but highly recommended, and it requires the use of another AWS service—[DynamoDB](https://aws.amazon.com/dynamodb/).

Let's configure it!

Here’s our plan to reinitialize Terraform using the S3 backend:

1. Add S3 and DynamoDB resource blocks before deleting the local state file.
2. Update the Terraform block to introduce the backend and state locking.
3. Reinitialize Terraform.
4. Delete the local `tfstate` file and verify the one stored in the S3 bucket.
5. Add `outputs`.
6. Run `terraform apply`.

To learn more about DynamoDB state locking, check out [this article](https://angelo-malatacca83.medium.com/aws-terraform-s3-and-dynamodb-backend-3b28431a76c1).

### 1. Create a file and name it `backend.tf`. Add the below code and replace the name of the S3 bucket you created in `project 17`

         ```bash
            resource "aws_s3_bucket" "terraform_state" {
            bucket = "citatech-terraform"

            # Add tags if needed
            tags = {
                Name = "terraform-state"
            }
            }

            resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
            resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
            bucket = aws_s3_bucket.terraform_state.bucket

            versioning_configuration {
                status = "Enabled"
            }
            }

            resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_encryption" {
            bucket = aws_s3_bucket.terraform_state.bucket

            rule {
                apply_server_side_encryption_by_default {
                sse_algorithm = "AES256"
                }
            }
            }
         ```
                                    

You should be aware that Terraform stores sensitive data, such as passwords and secret keys, within state files. Because of this, it’s crucial to always enable encryption to protect this information. You can see how we've implemented this using [server-side encryption configuration](https://docs.aws.amazon.com/AmazonS3/latest/userguide/serv-side-encryption.html).


### 2. Next, create a `DynamoDB` table to handle locks and perform consistency checks.

In previous projects, locks were handled with a local file as shown in __`terraform.tfstate.lock.info`__. Since we now have a team mindset, causing us to configure S3 as our backend to store state file, we will do the same to handle locking. Therefore, with a cloud storage database like DynamoDB, anyone running Terraform against the same infrastructure can use a central location to control a situation where Terraform is running at the same time from multiple different people.

Dynamo DB resource for locking and consistency checking:

                ```bash
                resource "aws_dynamodb_table" "terraform_locks" {
                name         = "terraform-locks"
                billing_mode = "PAY_PER_REQUEST"
                hash_key     = "LockID"
                attribute {
                    name = "LockID"
                    type = "S"
                }
                }
                ```

Terraform expects that both S3 bucket and DynamoDB resources are already created before we configure the backend. So, let us run `terraform apply` to provision resources.

### 3. Configure S3 Backend

        ```
        terraform {
        backend "s3" {
            bucket         = "citatech-terraform"
            key            = "global/s3/terraform.tfstate"
            region         = "eu-central-1"
            dynamodb_table = "terraform-locks"
            encrypt        = true
        }
        }

      

It's now time to reinitialize the backend. Run `terraform init` and confirm the backend change by typing `yes` when prompted.

![](./images/1.png)


### 4. Verify the changes

Open your AWS management console and you should see the following :

- `.tfstatefile` is now inside the S3 bucket

![](./images/2.png)

- DynamoDB table which we create has an entry which includes state file status

![](./images/3.png)

- Navigate to the DynamoDB table inside AWS and leave the page open in your browser. Run `terraform plan` and while that is running, refresh the browser and see how the lock is being handled:

![](./images/4.png)

After `terraform plan` completes, refresh DynamoDB table.

![](./images/5.png)

### 5. Add Terraform Output

Before we run `terraform apply` let us add an output so that the S3 bucket Amazon Resource Names ARN and DynamoDB table name can be displayed.

Create a new file and name it output.tf and add below code.

    ```
        output "s3_bucket_arn" {
        value       = aws_s3_bucket.terraform_state.arn
        description = "The ARN of the S3 bucket"
        }
        output "dynamodb_table_name" {
        value       = aws_dynamodb_table.terraform_locks.name
        description = "The name of the DynamoDB table"
        }

    ```

Now we have everything ready to go!

### 6. Let us run `terraform apply`

Terraform will automatically read the latest state from the S3 bucket to determine the current state of the infrastructure. Even if another engineer has applied changes, the state file will always be up to date.

Now, let's head over to the S3 console again, refresh the page, and click the grey “Show” button next to “Versions.” We should now see several versions of our terraform.tfstate file in the S3 bucket:

![image](./images/6.png)

Thanks to the remote backend and locking configuration we just set up, collaboration is no longer an issue.

However, another challenge remains: Environment Isolation. We often need to create resources for various environments, such as `Dev`, `SIT`, `UAT`, `Preprod`, `Prod`, etc.

This environment separation can be accomplished through one of two approaches:

a. Terraform Workspaces

b. Directory-based separation using the `terraform.tfvars` file

### When Should You Use `Workspaces` or `Directories`?

If your environments have significant configuration differences, it's best to use a directory structure. For environments that are mostly similar, workspaces are more suitable as they help avoid duplicating your configurations. Try both methods in the following sections to determine which is best for your infrastructure.

For now, you can read more about both options and experiment with them, but we’ll explore them in greater detail in upcoming projects.

## Refactoring Security Groups with __`dynamic block`__

For repetitive code blocks, you can use dynamic blocks in Terraform. To learn more about how to use them, check out this video.

### Refactor Security Groups creation with `dynamic blocks`.


![image](./images/7.png)

![image](./images/8.png)

![image](./images/9.png)

![image](./images/10.png)


## EC2 refactoring with `Map` and `Lookup`

Remember, every piece of work you do, always try to make it dynamic to accommodate future changes. [Amazon Machine Image (AMI)](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AMIs.html) is a regional service which means it is only available in the region it was created. But what if we change the region later, and want to dynamically pick up `AMI IDs` based on the available AMIs in that region? This is where we will introduce [Map](https://developer.hashicorp.com/terraform/language/functions/map) and [Lookup](https://developer.hashicorp.com/terraform/language/functions/lookup) functions.

Map uses a key and value pairs as a data structure that can be set as a default type for variables.

```hcl
variable "images" {
    type = "map"
    default = {
        us-east-1 = "image-1234"
        us-west-2 = "image-23834"
    }
}
```

To select an appropriate AMI per region, we will use a lookup function which has following syntax: __`lookup(map, key, [default])`__.

__Note:__ A default value is better to be used to avoid failure whenever the map data has no key.

    ```hcl
    resource "aws_instace" "web" {
        ami  = "${lookup(var.images, var.region), "ami-12323"}
    }
    ```
Now, the lookup function will load the variable `images` using the first parameter. But it also needs to know which of the key-value pairs to use. That is where the second parameter comes in. The key `us-east-1` could be specified, but then we will not be doing anything dynamic there, but if we specify the variable for region, it simply resolves to one of the keys. That is why we have used `var.region` in the second parameter.

# Conditional Expressions


If you need to make a decision and select a resource based on a specific condition, you should use Terraform Conditional Expressions.

The general syntax is: `condition ? true_val : false_val`

Review the following code snippet and see if you can understand its meaning:


    ```
        resource "aws_db_instance" "read_replica" {
        count               = var.create_read_replica == true ? 1 : 0
        replicate_source_db = aws_db_instance.this.id
        }
    ```

- true #condition equals to 'if true'
- ? #means, set to '1`
- : #means, otherwise, set to '0'

# Terraform Modules and Best Practices for Structuring Your `.tf` Code

By now, you may have noticed how challenging it can be to navigate through a single, lengthy `.tf` file with all your Terraform blocks. As a DevOps engineer, it’s essential to create reusable and well-organized IaC (Infrastructure as Code) structures. One of the tools Terraform provides to help with this is [Modules](https://developer.hashicorp.com/terraform/language/modules).

Modules act as containers that allow you to logically group Terraform code for related resources within the same domain (e.g., Compute, Networking, AMI, etc.). A `root module` can call `child modules` and integrate their configurations when applying the Terraform plan. This approach not only keeps your codebase clean and organized but also enables different team members to work on separate parts of the configuration simultaneously.

You can also create and publish your modules to the [Terraform Registry](https://registry.terraform.io/browse/modules) for others to use, or incorporate modules from the registry into your projects.

A module is simply a collection of `.tf` and/or `.tf.json` files within a directory.

You can reference existing child modules from your `root module` by specifying them as a source, like this:


        ```
        module "network" {
        source = "./modules/network"
        }
        ```

Keep in mind that the path to the 'network' module is relative to your working directory.

You can also directly access resource outputs from the modules, like this:

        ```
        resource "aws_elb" "example" {
        # ...

        instances = module.servers.instance_ids
        }
        ```

In the example above, you will have to have module 'servers' to have output file to expose variables for this resource.


## Refactor your project using Modules

Take a look at our  Project 17. You'll notice that we used a single, lengthy file to create all of our resources. However, this approach isn't ideal because it makes the codebase difficult to read and understand, and it can make future changes cumbersome and error-prone.

## QUICK TASK:

Break down your Terraform codes to have all resources in their respective modules. Combine resources of a similar type into directories within a 'modules' directory, for example, like this:

```css
- modules
  - ALB
  - EFS
  - RDS
  - Autoscaling
  - compute
  - VPC
  - security
```

![image](./images/11.png)


Each module should include the following files:

```css
    - `main.tf` (or `%resource_name%.tf`): Contains the resource blocks.
    - `outputs.tf` (optional): Use this if you need to reference outputs from these resources in your root module.
    - `variables.tf`: As we've discussed, it's a best practice to avoid hardcoding values and instead use variables.
```

It is also recommended to configure `providers` and `backends` sections in separate files.

__NOTE:__ It is not compulsory to use this naming convention.

After you have given it a try, you can check out this [repository](https://github.com/dareyio/PBL-project-18)

It is not compulsory to use this naming convention for guidiance or to fix your errors.

In the configuration sample from the repository, you can observe two examples of referencing the module:

a. Import module as a `source` and have access to its variables via `var` keyword:

    ```hcl
        module "VPC" {
        source = "./modules/VPC"
        region = var.region
        ...

b. Refer to a module's output by specifying the full path to the output variable by using __`module.%module_name%.%output_name%`__ construction:

        ```hcl
        subnets-compute = module.network.public_subnets-1
        ```

## Finalize the Terraform Configuration

Complete the remaining code on your own, so that the final configuration structure in your working directory looks like this:

 ```css
    └── PBL
        ├── modules
        |   ├── ALB
        |     ├── ... (module .tf files, e.g., main.tf, outputs.tf, variables.tf)
        |   ├── EFS
        |     ├── ... (module .tf files)
        |   ├── RDS
        |     ├── ... (module .tf files)
        |   ├── autoscaling
        |     ├── ... (module .tf files)
        |   ├── compute
        |     ├── ... (module .tf files)
        |   ├── network
        |     ├── ... (module .tf files)
        |   ├── security
        |     ├── ... (module .tf files)
        ├── main.tf
        ├── backends.tf
        ├── providers.tf
        ├── data.tf
        ├── outputs.tf
        ├── terraform.tfvars
        └── variables.tf
```

![image](./images/12.png)  ![image](./images/13.png)

![image](./images/14.png)

### Instantiating the Modules

![image](./images/15.png)



### Validate your terraform codes

You can make use of `terraform validate` to check your terraform codes for errors

![image](./images/16.png)


### Run `terraform plan`

![image](./images/17.png)

![image](./images/18.png)

![image](./images/19.png)

![image](./images/20.png)

![image](./images/21.png)

![image](./images/22.png)

![image](./images/23.png)

![image](./images/24.png)

![image](./images/25.png)

![image](./images/26.png)

![image](./images/27.png)

![image](./images/28.png)



### Run `terraform apply`


![image](./images/30.png)


![image](./images/31.png)

![image](./images/32.png)

![image](./images/33.png)

![image](./images/34.png)

![image](./images/35.png)

![image](./images/36.png)

![image](./images/37.png)

![image](./images/39.png)

![image](./images/40.png)


### Run `terraform state list`


![image](./images/29.png)


Now, the code is much better organized, making it easier for our DevOps team members to read, edit, and reuse.

__`BLOCKERS`:__ Our website is currently unavailable because the userdata scripts added to the launch template lack the latest endpoints for `EFS`, `ALB`, and `RDS`. Additionally, our AMI is not properly configured. So, how do we address this?

In the next project, Project 19, we will explore how to use Packer to create AMIs, Terraform to set up the infrastructure, and Ansible to configure it.

We will also learn how to use Terraform Cloud for managing our backends.

### Pro-tips:

1. We can validate our code before running `terraform plan` using the [terraform validate](https://developer.hashicorp.com/terraform/cli/commands/validate) command. This will check if our code is syntactically correct and internally consistent.

2. To ensure our configuration files are more readable and follow canonical formatting and style, we use the [terraform fmt](https://developer.hashicorp.com/terraform/cli/commands/fmt) command. It applies Terraform language style conventions and formats our `.tf` files accordingly.

### Conclusion

We have successfully developed and refactored AWS Infrastructure as Code using Terraform.


























