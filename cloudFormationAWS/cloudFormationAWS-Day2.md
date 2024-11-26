# **Intermediate AWS Project: VPC with Public and Private Subnets Using CloudFormation**

This project demonstrates creating an Amazon Virtual Private Cloud (VPC) with public and private subnets, an Internet Gateway, a NAT Gateway, EC2 instances, and associated **Security Groups**. It is implemented using **AWS CloudFormation**, showcasing how to manage infrastructure as code (IaC).

---

## **Table of Contents**
1. [Overview](#overview)
2. [Architecture Diagram](#architecture-diagram)
3. [Features](#features)
4. [CloudFormation Template Details](#cloudformation-template-details)
5. [Deployment Instructions](#deployment-instructions)
6. [Validation](#validation)
7. [Official AWS Documentation Links](#official-aws-documentation-links)

---

## **Overview**

This project creates the following AWS resources:
- A **VPC** with a CIDR block `11.0.0.0/16`.
- A **public subnet** (`11.0.2.0/24`) and a **private subnet** (`11.0.1.0/24`).
- An **Internet Gateway** attached to the VPC for internet access in the public subnet.
- A **NAT Gateway** in the public subnet for outbound internet access from the private subnet.
- **Elastic IP** for the NAT Gateway.
- Two **EC2 Instances**:
  - One in the public subnet.
  - Another in the private subnet.
- **Security Groups** that control access to the EC2 instances.
- **Route Tables**:
  - A public route table associated with the public subnet, allowing internet access.
  - A private route table associated with the private subnet, routing traffic via the NAT Gateway.

---

## **Architecture Diagram**

```plaintext
        VPC (11.0.0.0/16)
        ┌───────────────────────────────┐
        │                               │
        │  Public Subnet (11.0.2.0/24)  │
        │  ┌───────────────────────┐    │
        │  │   EC2 Instance        │    │
        │  │   + Security Group   │    │
        │  │                       │    │
        │  │  + NAT Gateway        │    │
        │  └───────────────────────┘    │
        │  Public Route Table           │
        │                               │
        │  Private Subnet (11.0.1.0/24) │
        │  ┌───────────────────────┐    │
        │  │   EC2 Instance        │    │
        │  │   + Security Group   │    │
        │  └───────────────────────┘    │
        │  Private Route Table          │
        │                               │
        └───────────────────────────────┘
```

In the diagram above:
- The **Security Groups** are applied to the EC2 instances, ensuring only authorized traffic can reach the instances.
- The **Public Instance** has an associated **Security Group** allowing SSH, HTTP, and HTTPS traffic.
- The **Private Instance** uses the same **Security Group** but has no direct internet access. It accesses the internet via the NAT Gateway.

---

## **Features**
1. **VPC and Subnets**: Efficient segregation of resources into public and private subnets.
2. **Routing**:
   - Public resources use an Internet Gateway for direct internet access.
   - Private resources use a NAT Gateway for secure outbound access.
3. **Elastic IP**: Ensures a static, accessible public IP for the NAT Gateway.
4. **EC2 Instances**: Launches sample instances in both subnets for testing connectivity.
5. **Security Groups**: Controls access to EC2 instances, allowing SSH, HTTP, and HTTPS traffic where needed.

---

## **CloudFormation Template Details**

### Template Breakdown

Below is the full CloudFormation template. Save it as `vpc-project.yaml`.

```yaml
AWSTemplateFormatVersion: "2010-09-09"
Description: Create a VPC with public and private subnets, an Internet Gateway, a NAT Gateway, Elastic IP, Route Tables, and EC2 instances.

Resources:
  # VPC
  MyVPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: 11.0.0.0/16
      EnableDnsSupport: true
      EnableDnsHostnames: true
      Tags:
        - Key: Name
          Value: MyVPC

  # Public Subnet
  PublicSubnet:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref MyVPC
      CidrBlock: 11.0.2.0/24
      MapPublicIpOnLaunch: true
      AvailabilityZone: !Select [ 0, !GetAZs '' ]
      Tags:
        - Key: Name
          Value: PublicSubnet

  # Private Subnet
  PrivateSubnet:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref MyVPC
      CidrBlock: 11.0.1.0/24
      MapPublicIpOnLaunch: false
      AvailabilityZone: !Select [ 0, !GetAZs '' ]
      Tags:
        - Key: Name
          Value: PrivateSubnet

  # Internet Gateway
  InternetGateway:
    Type: AWS::EC2::InternetGateway
    Properties:
      Tags:
        - Key: Name
          Value: MyInternetGateway

  AttachInternetGateway:
    Type: AWS::EC2::VPCGatewayAttachment
    Properties:
      VpcId: !Ref MyVPC
      InternetGatewayId: !Ref InternetGateway

  # Elastic IP for NAT Gateway
  NatElasticIP:
    Type: AWS::EC2::EIP

  # NAT Gateway
  NatGateway:
    Type: AWS::EC2::NatGateway
    Properties:
      AllocationId: !GetAtt NatElasticIP.AllocationId
      SubnetId: !Ref PublicSubnet

  # Public Route Table
  PublicRouteTable:
    Type: AWS::EC2::RouteTable
    Properties:
      VpcId: !Ref MyVPC
      Tags:
        - Key: Name
          Value: PublicRouteTable

  PublicRoute:
    Type: AWS::EC2::Route
    Properties:
      RouteTableId: !Ref PublicRouteTable
      DestinationCidrBlock: 0.0.0.0/0
      GatewayId: !Ref InternetGateway

  PublicSubnetRouteTableAssociation:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      SubnetId: !Ref PublicSubnet
      RouteTableId: !Ref PublicRouteTable

  # Private Route Table
  PrivateRouteTable:
    Type: AWS::EC2::RouteTable
    Properties:
      VpcId: !Ref MyVPC
      Tags:
        - Key: Name
          Value: PrivateRouteTable

  PrivateRoute:
    Type: AWS::EC2::Route
    Properties:
      RouteTableId: !Ref PrivateRouteTable
      DestinationCidrBlock: 0.0.0.0/0
      NatGatewayId: !Ref NatGateway

  PrivateSubnetRouteTableAssociation:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      SubnetId: !Ref PrivateSubnet
      RouteTableId: !Ref PrivateRouteTable

  # Security Group for EC2 Instances (Public & Private)
  Ec2SecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: "Allow SSH, HTTP, and HTTPS inbound traffic"
      VpcId: !Ref MyVPC
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: "22"
          ToPort: "22"
          CidrIp: 0.0.0.0/0  # Allow SSH from anywhere (can be restricted to specific IPs for better security)
        - IpProtocol: tcp
          FromPort: "80"
          ToPort: "80"
          CidrIp: 0.0.0.0/0  # Allow HTTP from anywhere
        - IpProtocol: tcp
          FromPort: "443"
          ToPort: "443"
          CidrIp: 0.0.0.0/0  # Allow HTTPS from anywhere

  # EC2 Instances
  PublicInstance:
    Type: AWS::EC2::Instance
    Properties:
      InstanceType: t2.micro
      SubnetId: !Ref PublicSubnet
      ImageId: ami-0abcdef1234567890  # Replace with a valid AMI ID
      SecurityGroupIds:
        - !Ref Ec2SecurityGroup  # Attach Security Group to Public Instance
      Tags:
        - Key: Name
          Value: PublicInstance

  PrivateInstance:
    Type: AWS::EC2::Instance
    Properties:
      InstanceType: t2.micro
      SubnetId: !Ref PrivateSubnet
      ImageId: ami-0abcdef1234567890  # Replace with a valid AMI ID
      SecurityGroupIds:
        - !Ref Ec2SecurityGroup  # Attach Security Group to Private Instance
      Tags:
        - Key: Name
          Value: PrivateInstance
```

---

## **Deployment Instructions**

### 1.

 Save the Template
Save the above YAML file as `vpc-project.yaml` locally.

### 2. Deploy Using AWS CLI
Run the following command to deploy the stack:
```bash
aws cloudformation create-stack \
    --stack-name MyVPCProject \
    --template-body file://vpc-project.yaml \
    --region ap-southeast-1 \
    --capabilities CAPABILITY_NAMED_IAM
```

### 3. Validate the Resources
- Navigate to the **AWS Management Console**.
- Go to **VPC**, **Subnets**, **EC2 Instances**, and **Security Groups** to verify the resources.

### 4. Delete the Stack (Optional)
If you no longer need the stack, delete it:
```bash
aws cloudformation delete-stack --stack-name MyVPCProject --region ap-southeast-1
```

---

## **Validation**
1. Verify that the EC2 instance in the public subnet has internet access.
2. Verify that the private EC2 instance can connect to the internet through the NAT Gateway.
3. Check that the Security Group rules are correctly applied, ensuring the right access is provided to the EC2 instances.

---

## **Official AWS Documentation Links**
- [AWS::EC2::VPC](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-ec2-vpc.html)
- [AWS::EC2::Subnet](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-ec2-subnet.html)
- [AWS::EC2::InternetGateway](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-ec2-internetgateway.html)
- [AWS::EC2::NATGateway](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-ec2-natgateway.html)
- [AWS::EC2::RouteTable](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-ec2-routetable.html)
- [AWS::EC2::SecurityGroup](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-ec2-securitygroup.html)

---

## Let's break down the VPC part and all associated components in detail, explaining each property, what it does, and how it works.

---

### **VPC Resource - `MyVPC`**

```yaml
MyVPC:
  Type: AWS::EC2::VPC
  Properties:
    CidrBlock: 11.0.0.0/16
    EnableDnsSupport: true
    EnableDnsHostnames: true
    Tags:
      - Key: Name
        Value: MyVPC
```

#### **CidrBlock**
- **CIDR Block (`11.0.0.0/16`)**: The **CIDR block** defines the IP address range for your VPC. Here, `11.0.0.0/16` allows for 65,536 IP addresses within the VPC. The `/16` notation means the first 16 bits of the address are fixed, and the rest can be used for subnetting. This is a large enough range to support multiple subnets and instances.

#### **EnableDnsSupport**
- **EnableDnsSupport: true**: This enables DNS resolution for the VPC, meaning instances inside the VPC can resolve domain names (e.g., `ec2.amazonaws.com`) to IP addresses. By default, DNS support is enabled when creating a VPC, but this property ensures it is explicitly set.

#### **EnableDnsHostnames**
- **EnableDnsHostnames: true**: When set to `true`, this enables instances in the VPC to have DNS hostnames, such as `ec2-xx-xx-xx-xx.compute-1.amazonaws.com`, instead of just IP addresses. This is important for situations where you want to connect to EC2 instances by a hostname rather than an IP address. This is only useful if **EnableDnsSupport** is set to `true`.

---

### **Subnets - Public and Private**

#### **Public Subnet**

```yaml
PublicSubnet:
  Type: AWS::EC2::Subnet
  Properties:
    VpcId: !Ref MyVPC
    CidrBlock: 11.0.2.0/24
    MapPublicIpOnLaunch: true
    AvailabilityZone: !Select [ 0, !GetAZs '' ]
    Tags:
      - Key: Name
        Value: PublicSubnet
```

- **VpcId**: References the VPC (`MyVPC`) this subnet will belong to.
- **CidrBlock**: The CIDR block `11.0.2.0/24` defines the IP range for the public subnet. This allows for 256 IP addresses in this subnet (from `11.0.2.0` to `11.0.2.255`).
- **MapPublicIpOnLaunch**: This is set to `true`, meaning that any EC2 instance launched in this subnet will automatically be assigned a **public IP**. This is required for instances that need to be publicly accessible, such as a web server.
- **AvailabilityZone**: The `!Select [ 0, !GetAZs '' ]` function chooses an availability zone from the available ones in the region. `!GetAZs ''` returns all available availability zones for the current region, and `!Select [0, ...]` picks the first one. This ensures the subnet is created in a specific availability zone.

#### **Private Subnet**

```yaml
PrivateSubnet:
  Type: AWS::EC2::Subnet
  Properties:
    VpcId: !Ref MyVPC
    CidrBlock: 11.0.1.0/24
    MapPublicIpOnLaunch: false
    AvailabilityZone: !Select [ 0, !GetAZs '' ]
    Tags:
      - Key: Name
        Value: PrivateSubnet
```

- Similar to the public subnet but with key differences:
- **CidrBlock**: The CIDR block `11.0.1.0/24` allocates IPs for the private subnet, with 256 IP addresses.
- **MapPublicIpOnLaunch**: This is set to `false` because instances in the private subnet should not have direct internet access (i.e., no public IP).
- **AvailabilityZone**: Again, uses `!Select [ 0, !GetAZs '' ]` to pick an availability zone, ensuring the private subnet is created in the same zone as the public subnet.

---

### **Internet Gateway**

```yaml
InternetGateway:
  Type: AWS::EC2::InternetGateway
  Properties:
    Tags:
      - Key: Name
        Value: MyInternetGateway
```

- **InternetGateway**: This resource represents a gateway that allows communication between your VPC and the public internet. It provides outbound internet access for resources in public subnets (like an EC2 instance running a web server).
- **Tags**: Adds a `Name` tag to help identify the Internet Gateway in the AWS Management Console.

---

### **VPC Gateway Attachment**

```yaml
AttachInternetGateway:
  Type: AWS::EC2::VPCGatewayAttachment
  Properties:
    VpcId: !Ref MyVPC
    InternetGatewayId: !Ref InternetGateway
```

- **VpcId**: Associates the Internet Gateway (`InternetGateway`) with the VPC (`MyVPC`).
- **InternetGatewayId**: Specifies the ID of the Internet Gateway, which will be attached to the VPC to provide internet access.

---

### **Elastic IP for NAT Gateway**

```yaml
NatElasticIP:
  Type: AWS::EC2::EIP
```

- **Elastic IP (EIP)**: An Elastic IP is a static IPv4 address designed for dynamic cloud computing. It is associated with the NAT Gateway and allows for persistent internet access even if the underlying infrastructure changes (e.g., if the instance is stopped and restarted).

---

### **NAT Gateway**

```yaml
NatGateway:
  Type: AWS::EC2::NatGateway
  Properties:
    AllocationId: !GetAtt NatElasticIP.AllocationId
    SubnetId: !Ref PublicSubnet
```

- **AllocationId**: Uses `!GetAtt NatElasticIP.AllocationId` to reference the Elastic IP (EIP) allocated in the previous step. This EIP is associated with the NAT Gateway to allow instances in the private subnet to access the internet.
- **SubnetId**: Specifies the **public subnet** (`PublicSubnet`) where the NAT Gateway will reside. This ensures the NAT Gateway is publicly accessible, while still enabling private instances to access the internet indirectly.

---

### **Route Tables for Public and Private Subnets**

#### **Public Route Table**

```yaml
PublicRouteTable:
  Type: AWS::EC2::RouteTable
  Properties:
    VpcId: !Ref MyVPC
    Tags:
      - Key: Name
        Value: PublicRouteTable
```

- **VpcId**: Associates the route table with the `MyVPC` VPC.
- **Tags**: Adds a `Name` tag to identify the route table.

#### **Public Route**

```yaml
PublicRoute:
  Type: AWS::EC2::Route
  Properties:
    RouteTableId: !Ref PublicRouteTable
    DestinationCidrBlock: 0.0.0.0/0
    GatewayId: !Ref InternetGateway
```

- **RouteTableId**: References the route table associated with the public subnet.
- **DestinationCidrBlock**: `0.0.0.0/0` refers to all IP addresses. This route is for directing all traffic to the Internet Gateway (`InternetGateway`), allowing instances in the public subnet to access the internet.

#### **Public Subnet Route Table Association**

```yaml
PublicSubnetRouteTableAssociation:
  Type: AWS::EC2::SubnetRouteTableAssociation
  Properties:
    SubnetId: !Ref PublicSubnet
    RouteTableId: !Ref PublicRouteTable
```

- **SubnetId**: Associates the public subnet with the public route table. This ensures that instances in the public subnet can route traffic to the internet via the Internet Gateway.

#### **Private Route Table**

```yaml
PrivateRouteTable:
  Type: AWS::EC2::RouteTable
  Properties:
    VpcId: !Ref MyVPC
    Tags:
      - Key: Name
        Value: PrivateRouteTable
```

- Similar to the public route table, but this route table will route traffic through the NAT Gateway for private subnet instances.

#### **Private Route**

```yaml
PrivateRoute:
  Type: AWS::EC2::Route
  Properties:
    RouteTableId: !Ref PrivateRouteTable
    DestinationCidrBlock: 0.0.0.0/0
    NatGatewayId: !Ref NatGateway
```

- **NatGatewayId**: Specifies the NAT Gateway (`NatGateway`) for routing internet-bound traffic from the private subnet. This allows private instances to access the internet while keeping them hidden behind the NAT Gateway.

#### **Private Subnet Route Table Association**

```yaml
PrivateSubnetRouteTableAssociation:
  Type: AWS::EC2::SubnetRouteTableAssociation
  Properties:
    SubnetId: !Ref PrivateSubnet
    RouteTableId: !Ref PrivateRouteTable
```

- Associates the private subnet with the private route table. This allows instances in the private subnet to route traffic through the NAT Gateway.

---

### **Security Group for EC2 Instances**

```yaml
Ec2SecurityGroup:
  Type: AWS::EC2::SecurityGroup
  Properties:
    GroupDescription: "Allow SSH, HTTP, and HTTPS inbound traffic"
    VpcId: !Ref MyVPC
    SecurityGroupIngress:
      - IpProtocol:

 tcp
        FromPort: "22"
        ToPort: "22"
        CidrIp: 0.0.0.0/0  # Allow SSH from anywhere (can be restricted to specific IPs for better security)
      - IpProtocol: tcp
        FromPort: "80"
        ToPort: "80"
        CidrIp: 0.0.0.0/0  # Allow HTTP from anywhere
      - IpProtocol: tcp
        FromPort: "443"
        ToPort: "443"
        CidrIp: 0.0.0.0/0  # Allow HTTPS from anywhere
```

- **Security Group**: Controls the inbound and outbound traffic to EC2 instances. This security group allows:
  - **SSH (Port 22)** from anywhere (`0.0.0.0/0`)
  - **HTTP (Port 80)** from anywhere (`0.0.0.0/0`)
  - **HTTPS (Port 443)** from anywhere (`0.0.0.0/0`)

---

### **EC2 Instances**

Both public and private EC2 instances are launched with specific configurations like instance type, subnet, and security group.

#### **Public EC2 Instance**

```yaml
PublicInstance:
  Type: AWS::EC2::Instance
  Properties:
    InstanceType: t2.micro
    SubnetId: !Ref PublicSubnet
    ImageId: ami-0abcdef1234567890  # Replace with a valid AMI ID
    SecurityGroupIds:
      - !Ref Ec2SecurityGroup  # Attach Security Group to Public Instance
    Tags:
      - Key: Name
        Value: PublicInstance
```

- **InstanceType**: Defines the instance type (e.g., `t2.micro`).
- **SubnetId**: Specifies the public subnet (`PublicSubnet`) where the instance will be launched.
- **SecurityGroupIds**: Associates the instance with the security group to allow SSH, HTTP, and HTTPS.
- **ImageId**: A placeholder for the Amazon Machine Image (AMI) ID to launch the instance with the desired operating system.

#### **Private EC2 Instance**

```yaml
PrivateInstance:
  Type: AWS::EC2::Instance
  Properties:
    InstanceType: t2.micro
    SubnetId: !Ref PrivateSubnet
    ImageId: ami-0abcdef1234567890  # Replace with a valid AMI ID
    SecurityGroupIds:
      - !Ref Ec2SecurityGroup  # Attach Security Group to Private Instance
    Tags:
      - Key: Name
        Value: PrivateInstance
```

- **SubnetId**: Specifies the private subnet (`PrivateSubnet`) for the private instance.

---
