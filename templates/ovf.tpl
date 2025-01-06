<?xml version="1.0"?>
<Envelope ovf:version="1.0" xml:lang="en-US" xmlns="http://schemas.dmtf.org/ovf/envelope/1" xmlns:ovf="http://schemas.dmtf.org/ovf/envelope/1" xmlns:rasd="http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_ResourceAllocationSettingData" xmlns:vssd="http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_VirtualSystemSettingData" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:vbox="http://www.virtualbox.org/ovf/machine">
  <References>
    <File ovf:id="file1" ovf:href="${VM_NAME}-disk001.vmdk"/>
  </References>
  <DiskSection>
    <Info>List of the virtual disks used in the package</Info>
    <Disk ovf:capacity="${DISK_SIZE}" ovf:diskId="vmdisk1" ovf:fileRef="file1" ovf:format="http://www.vmware.com/interfaces/specifications/vmdk.html#streamOptimized" vbox:uuid="${disk_uuid}"/>
  </DiskSection>
  <NetworkSection>
    <Info>Logical networks used in the package</Info>
    <Network ovf:name="NAT">
      <Description>Logical network used by this appliance.</Description>
    </Network>
  </NetworkSection>
  <VirtualSystem ovf:id="${VM_NAME}">
    <Info>A virtual machine</Info>
    <OperatingSystemSection ovf:id="94">
      <Info>The kind of installed guest operating system</Info>
      <Description>Ubuntu_arm64</Description>
      <vbox:OSType ovf:required="false">Ubuntu_arm64</vbox:OSType>
    </OperatingSystemSection>
    <VirtualHardwareSection>
      <Info>Virtual hardware requirements for a virtual machine</Info>
      <System>
        <vssd:ElementName>Virtual Hardware Family</vssd:ElementName>
        <vssd:InstanceID>0</vssd:InstanceID>
        <vssd:VirtualSystemIdentifier>${VM_NAME}</vssd:VirtualSystemIdentifier>
        <vssd:VirtualSystemType>virtualbox-2.2</vssd:VirtualSystemType>
      </System>
      <Item>
        <rasd:Caption>1 virtual CPU</rasd:Caption>
        <rasd:Description>Number of virtual CPUs</rasd:Description>
        <rasd:ElementName>1 virtual CPU</rasd:ElementName>
        <rasd:InstanceID>1</rasd:InstanceID>
        <rasd:ResourceType>3</rasd:ResourceType>
        <rasd:VirtualQuantity>1</rasd:VirtualQuantity>
      </Item>
      <Item>
        <rasd:AllocationUnits>MegaBytes</rasd:AllocationUnits>
        <rasd:Caption>${MEMORY} MB of memory</rasd:Caption>
        <rasd:Description>Memory Size</rasd:Description>
        <rasd:ElementName>${MEMORY} MB of memory</rasd:ElementName>
        <rasd:InstanceID>2</rasd:InstanceID>
        <rasd:ResourceType>4</rasd:ResourceType>
        <rasd:VirtualQuantity>${MEMORY}</rasd:VirtualQuantity>
      </Item>
      <Item>
        <rasd:Address>0</rasd:Address>
        <rasd:Caption>virtioController0</rasd:Caption>
        <rasd:Description>Virtio Controller</rasd:Description>
        <rasd:ElementName>virtioController0</rasd:ElementName>
        <rasd:InstanceID>3</rasd:InstanceID>
        <rasd:ResourceSubType>VirtioSCSI</rasd:ResourceSubType>
        <rasd:ResourceType>20</rasd:ResourceType>
      </Item>
      <Item>
        <rasd:AutomaticAllocation>true</rasd:AutomaticAllocation>
        <rasd:Caption>Ethernet adapter on 'NAT'</rasd:Caption>
        <rasd:Connection>NAT</rasd:Connection>
        <rasd:ElementName>Ethernet adapter on 'NAT'</rasd:ElementName>
        <rasd:InstanceID>4</rasd:InstanceID>
        <rasd:ResourceType>10</rasd:ResourceType>
      </Item>
      <Item>
        <rasd:AddressOnParent>0</rasd:AddressOnParent>
        <rasd:Caption>disk1</rasd:Caption>
        <rasd:Description>Disk Image</rasd:Description>
        <rasd:ElementName>disk1</rasd:ElementName>
        <rasd:HostResource>/disk/vmdisk1</rasd:HostResource>
        <rasd:InstanceID>5</rasd:InstanceID>
        <rasd:Parent>3</rasd:Parent>
        <rasd:ResourceType>17</rasd:ResourceType>
      </Item>
    </VirtualHardwareSection>
    <vbox:Machine ovf:required="false" version="1.20-macosx" uuid="{${vm_uuid}}" name="${VM_NAME}" OSType="Ubuntu_arm64" snapshotFolder="Snapshots">
      <ovf:Info>Complete VirtualBox machine configuration in VirtualBox format</ovf:Info>
      <Hardware>
        <CPU>
          <PAE enabled="false"/>
        </CPU>
        <Memory RAMSize="${MEMORY}"/>
        <Boot>
          <Order position="1" device="HardDisk"/>
          <Order position="2" device="DVD"/>
          <Order position="3" device="Floppy"/>
          <Order position="4" device="None"/>
        </Boot>
        <Display controller="VMSVGA" VRAMSize="16"/>
        <VideoCapture enabled="false"/>
        <RemoteDisplay enabled="false"/>
        <USB>
          <Controllers>
            <Controller name="xHCI" type="XHCI"/>
          </Controllers>
        </USB>
        <Network>
          <Adapter slot="0" enabled="true" MACAddress="080027F0F51D" type="virtio">
            <NAT localhost-reachable="true"/>
          </Adapter>
        </Network>
        <AudioAdapter driver="CoreAudio" controller="HDA" enabled="true" enabledIn="false" enabledOut="true"/>
        <RTC localOrUTC="UTC"/>
        <Clipboard mode="Disabled"/>
        <StorageControllers>
          <StorageController name="Virtio Controller" type="VirtioSCSI" PortCount="1" useHostIOCache="false" Bootable="true">
            <AttachedDevice type="HardDisk" port="0" device="0">
              <Image uuid="{${disk_uuid}}"/>
            </AttachedDevice>
          </StorageController>
        </StorageControllers>
      </Hardware>
      <Platform architecture="ARM">
        <CPU/>
      </Platform>
    </vbox:Machine>
  </VirtualSystem>
</Envelope>